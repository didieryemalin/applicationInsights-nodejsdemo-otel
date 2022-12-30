var express = require('express');
const axios = require('axios');
var Task = require('../models/task');

const opentelemetry = require("@opentelemetry/api");
const tracer = opentelemetry.trace.getTracer("ai-nodejsdemo-otel-tracer")

var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  const span = tracer. .startSpan("ai-nodejsdemo-otel-homepage");

  Task.find()
    .then((tasks) => {      
      const currentTasks = tasks.filter(task => !task.completed);
      const completedTasks = tasks.filter(task => task.completed === true);

      span.addEvent("loading home page");

      console.log(`Total tasks: ${tasks.length}   Current tasks: ${currentTasks.length}    Completed tasks:  ${completedTasks.length}`)
      res.render('index', { currentTasks: currentTasks, completedTasks: completedTasks, emailServiceResponse: 'Not sent' });
    })
    .catch((err) => {
      console.log(err);
      res.send('Sorry! Something went wrong.');
    });
  
  span.end();
});


router.post('/addTask', function(req, res, next) {
  const span = tracer.startSpan("ai-nodejsdemo-otel-newtask");

  const taskName = req.body.taskName;
  const createDate = Date.now();
  
  var task = new Task({
    taskName: taskName,
    createDate: createDate
  });
  console.log(`Adding a new task ${taskName} - createDate ${createDate}`)

  span.addEvent(`Adding a new task ${taskName} - createDate ${createDate}`);

  task.save()
      .then(() => { 
        console.log(`Added new task ${taskName} - createDate ${createDate}`)        
        res.redirect('/'); })
      .catch((err) => {
          console.log(err);
          res.send('Sorry! Something went wrong.');
      });
  
  span.end();
});

router.post('/completeTask', function(req, res, next) {
  const span = tracer.startSpan("ai-nodejsdemo-otel-completetask");
  
  const taskId = req.body._id;
  const completedDate = Date.now();

  span.addEvent(`Completing task ${taskId}`);

  Task.findByIdAndUpdate(taskId, { completed: true, completedDate: Date.now()})
    .then(() => {
      console.log(`Completed task ${taskId}`)
      res.redirect('/'); }  )
    .catch((err) => {
      console.log(err);
      res.send('Sorry! Something went wrong.');
    });
  
  span.end();
});

router.post('/deleteTask', function(req, res, next) {
  const span = tracer.startSpan("ai-nodejsdemo-otel-deletetask");

  const taskId = req.body._id;
  const completedDate = Date.now();

  span.addEvent(`Deleting task ${taskId}`);

  Task.findByIdAndDelete(taskId)
    .then(() => { 
      console.log(`Deleted task $(taskId)`)      
      res.redirect('/'); }  )
    .catch((err) => {
      console.log(err);
      res.send('Sorry! Something went wrong.');
    });

  span.end();
});

router.post('/emailTasks', function(req, res, next){
  const span = tracer.startSpan("ai-nodejsdemo-otel-emailtask");

  const emailAddress = req.body.emailAddress;
  console.log("email is " + emailAddress);

  if(emailAddress){

    Task.find()
    .then((tasks) => {      
      const currentTasks = tasks.filter(task => !task.completed);
      const completedTasks = tasks.filter(task => task.completed === true);

      console.log(`Total tasks: ${tasks.length}   Current tasks: ${currentTasks.length}    Completed tasks:  ${completedTasks.length}`)
      
      console.log("About to send tasks to task processor API");
      span.addEvent("About to send tasks to task processor API");
      
      axios.post(process.env.TASK_PROCESSOR_URL, { 
        emailAddress: emailAddress, 
        currentTasks: currentTasks, 
        completedTasks: completedTasks 
      })
      .then(function(response){
        console.log("Tasks sent to Task processor API")
      })
      .catch(function(error){
        console.log(error);
      });

      res.redirect('/');
    })
    .catch((err) => {
      console.log(err);
      res.send('Sorry! Something went wrong.');
    });
  }

  span.end();
});

module.exports = router;