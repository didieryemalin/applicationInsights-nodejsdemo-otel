const opentelemetry = require("@opentelemetry/api");
const { diag, DiagConsoleLogger, DiagLogLevel } = require("@opentelemetry/api");
const { Resource } = require("@opentelemetry/resources");
const { SemanticResourceAttributes } = require("@opentelemetry/semantic-conventions");
const { NodeTracerProvider } = require("@opentelemetry/sdk-trace-node");
const { registerInstrumentations } = require("@opentelemetry/instrumentation");
const { BatchSpanProcessor, ConsoleSpanExporter } = require("@opentelemetry/sdk-trace-base");
const { AzureMonitorTraceExporter } = require("@azure/monitor-opentelemetry-exporter");
const { getNodeAutoInstrumentations } = require("@opentelemetry/auto-instrumentations-node");
const { HttpInstrumentation } = require("@opentelemetry/instrumentation-http");
const { ExpressInstrumentation } = require("@opentelemetry/instrumentation-express");
const { MongooseInstrumentation } = require('opentelemetry-instrumentation-mongoose');
const { get } = require("mongoose");
require("dotenv").config();

// Register all otel-maintained auto instrumentation libraries
// registerInstrumentations({
//   instrumentations: [
//     getNodeAutoInstrumentations()
//   ],
// });

// Optionally register instrumentation libraries
registerInstrumentations({
  instrumentations: [
    new HttpInstrumentation(),
    new ExpressInstrumentation(),
    new MongooseInstrumentation()
  ],
});

const resource =
  Resource.default().merge(
    new Resource({
      [SemanticResourceAttributes.SERVICE_NAME]: "nodejs-otel-demo",
      [SemanticResourceAttributes.SERVICE_VERSION]: "0.1.0",
    })
  );

const provider = new NodeTracerProvider({
    resource: resource,
});

// Use this line for debugging
//diag.setLogger(new DiagConsoleLogger(), DiagLogLevel.ALL);

const exporter = new AzureMonitorTraceExporter({
    connectionString: process.env.APPINSIGHTS_CONN_STRING
});

const processor = new BatchSpanProcessor(exporter, {
    bufferTimeout: 15000,
    bufferSize: 1000
});

provider.addSpanProcessor(processor);
provider.register();

// Below is how you can use the tracer to send traces manually
// const tracer = opentelemetry.trace.getTracer("nodejs-otel-demo-tracer")

// // Create a span. A span must be closed.
// const parentSpan = tracer.startSpan("main");
// for (let i = 0; i < 10; i += 1) {
//    doWork(parentSpan);
// }
// // Be sure to end the span.
// parentSpan.end();

// function doWork(parent) {
//   // Start another span. In this example, the main method already started a
//   // span, so that will be the parent span, and this will be a child span.
//   const ctx = opentelemetry.trace.setSpan(opentelemetry.context.active(), parent);
//   const span = tracer.startSpan("doWork", undefined, ctx);
//   // Simulate some random work.
//   for (let i = 0; i <= Math.floor(Math.random() * 40000000); i += 1) {
//     // empty
//   }
//   // Set attributes to the span.
//   span.setAttribute("test", "testValue");
//   // Annotate our span to capture metadata about our operation.
//   span.addEvent("invoking doWork");
//   span.end();
// }