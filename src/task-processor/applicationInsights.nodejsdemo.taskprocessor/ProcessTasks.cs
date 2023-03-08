using System;
using System.IO;
using System.Threading.Tasks;

using Microsoft.Azure.WebJobs;
using Microsoft.AspNetCore.Mvc;
using Microsoft.AspNetCore.Http;
using Microsoft.Extensions.Logging;
using Microsoft.ApplicationInsights;
using Microsoft.Azure.WebJobs.Extensions.Http;
using Microsoft.ApplicationInsights.Extensibility;

using Newtonsoft.Json;

using ApplicationInsights.Nodejsdemo.TaskProcessor.Models;
using ApplicationInsights.Nodejsdemo.TaskProcessor.Helpers;

namespace ApplicationInsights.Nodejsdemo.TaskProcessor
{
    public class ProcessTasks
    {
        private readonly TelemetryClient telemetryClient;

        /// Using dependency injection will guarantee that you use the same configuration for telemetry collected automatically and manually.
        public ProcessTasks(TelemetryConfiguration telemetryConfiguration)
        {
            telemetryClient = new TelemetryClient(telemetryConfiguration);
        }

        [FunctionName("ProcessTasks")]
        public async Task<IActionResult> Run(
            [HttpTrigger(AuthorizationLevel.Anonymous, "get", "post", Route = null)] HttpRequest req,
            ExecutionContext context, ILogger log)
        {
            log.LogInformation("Received tasks to be processed");

            try
            {
                // Get incoming data
                string requestBody = await new StreamReader(req.Body).ReadToEndAsync();
                var data = JsonConvert.DeserializeObject<TaskProcessingRequest>(requestBody);

                log.LogInformation($"Processing tasks to be sent to {data.EmailAddress}");

                // Transform it
                var currentTasksSummary = TaskHelper.BuildTasksSummary(data.CurrentTasks);
                var completedTasksSummary = TaskHelper.BuildTasksSummary(data.CompletedTasks);

                log.LogInformation($"Current tasks are: {currentTasksSummary}");
                log.LogInformation($"Completed tasks are: {completedTasksSummary}");

                var taskNotification = new TaskNotification()
                {
                    EmailAddress = data.EmailAddress,
                    CurrentTasks = currentTasksSummary,
                    CompletedTasks = completedTasksSummary
                };

                // Send it to email service
                var success = EmailHelper.SendDataToEmailService(taskNotification, log);

                if (success)
                {
                    // Save record trail to database
                    CosmosDBHelper.Setup();
                    CosmosDBHelper.CreateTaskNotification(taskNotification, telemetryClient, log);

                    return new OkObjectResult(new { Message = "success" });
                }
            }
            catch (Exception ex)
            {
                log.LogCritical($"Failed to process tasks for email", ex);
            }

            return new BadRequestObjectResult( new { Message = "failure" });
        }
    }
}
