var express = require('express');
const axios = require('axios');
var Task = require('../models/task');

var router = express.Router();

/* GET home page. */
router.get('/', function(req, res, next) {
  Task.find()
    .then((tasks) => {      
      const currentTasks = tasks.filter(task => !task.completed);
      const completedTasks = tasks.filter(task => task.completed === true);

      console.log(`Total tasks: ${tasks.length}   Current tasks: ${currentTasks.length}    Completed tasks:  ${completedTasks.length}`)
      res.render('index', { currentTasks: currentTasks, completedTasks: completedTasks, emailServiceResponse: 'Not sent' });
    })
    .catch((err) => {
      console.log(err);
      res.send('Sorry! Something went wrong.');
    });
});


router.post('/addTask', function(req, res, next) {
  const taskName = req.body.taskName;
  const createDate = Date.now();
  
  var task = new Task({
    taskName: taskName,
    createDate: createDate
  });
  console.log(`Adding a new task ${taskName} - createDate ${createDate}`)

  task.save()
      .then(() => { 
        console.log(`Added new task ${taskName} - createDate ${createDate}`)        
        res.redirect('/'); })
      .catch((err) => {
          console.log(err);
          res.send('Sorry! Something went wrong.');
      });
});

router.post('/completeTask', function(req, res, next) {
  console.log("I am in the PUT method")
  const taskId = req.body._id;
  const completedDate = Date.now();

  Task.findByIdAndUpdate(taskId, { completed: true, completedDate: Date.now()})
    .then(() => { 
      console.log(`Completed task ${taskId}`)
      res.redirect('/'); }  )
    .catch((err) => {
      console.log(err);
      res.send('Sorry! Something went wrong.');
    });
});


router.post('/deleteTask', function(req, res, next) {
  const taskId = req.body._id;
  const completedDate = Date.now();
  Task.findByIdAndDelete(taskId)
    .then(() => { 
      console.log(`Deleted task $(taskId)`)      
      res.redirect('/'); }  )
    .catch((err) => {
      console.log(err);
      res.send('Sorry! Something went wrong.');
    });
});

router.post('/emailTasks', function(req, res, next){
  const emailAddress = req.body.emailAddress;
  console.log("email is " + emailAddress);

  if(emailAddress){

    Task.find()
    .then((tasks) => {      
      const currentTasks = tasks.filter(task => !task.completed);
      const completedTasks = tasks.filter(task => task.completed === true);

      console.log(`Total tasks: ${tasks.length}   Current tasks: ${currentTasks.length}    Completed tasks:  ${completedTasks.length}`)
      
      console.log("About to email tasks");
      
      const currentTasksSummary = getTasksSummary(currentTasks);
      const completedTasksSummary = getTasksSummary(completedTasks);

      axios.post(process.env.EMAIL_SERVICE_URL, { 
          emailAddress: emailAddress, 
          currentTasks: currentTasksSummary, 
          completedTasks: completedTasksSummary 
        })
        .then(function(response){
          //console.log(response);
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
});

function getTasksSummary(tasks){
  let tasksSummary = "";

  for(let i = 0; i < tasks.length; i++){
    tasksSummary = (i == (tasks.length - 1)) ? (tasksSummary + tasks[i].taskName) : (tasksSummary + `${tasks[i].taskName}, `)
  }
  
  console.log(tasksSummary);
  return tasksSummary;
};

module.exports = router;
