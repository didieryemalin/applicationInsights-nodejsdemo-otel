
namespace ApplicationInsights.Nodejsdemo.TaskProcessor.Models
{
    public class TaskNotification
    {
        public string EmailAddress { get; set; }

        public string CurrentTasks { get; set; }

        public string CompletedTasks { get; set; }
    }
}
