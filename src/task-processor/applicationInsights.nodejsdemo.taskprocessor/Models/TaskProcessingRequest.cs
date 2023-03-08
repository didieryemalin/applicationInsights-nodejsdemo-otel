using System.Collections.Generic;

namespace ApplicationInsights.Nodejsdemo.TaskProcessor.Models
{
    public class TaskProcessingRequest
    {
        public string EmailAddress { get; set; }

        public List<TodoTask> CurrentTasks { get; set; } = new List<TodoTask> { };

        public List<TodoTask> CompletedTasks { get; set; } = new List<TodoTask> { };
    }
}
