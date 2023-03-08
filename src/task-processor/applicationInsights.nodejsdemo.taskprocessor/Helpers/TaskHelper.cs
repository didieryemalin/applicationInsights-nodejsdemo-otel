using System;
using System.Collections.Generic;

using ApplicationInsights.Nodejsdemo.TaskProcessor.Models;

namespace ApplicationInsights.Nodejsdemo.TaskProcessor.Helpers
{
    public static class TaskHelper
    {
        public static string BuildTasksSummary(List<TodoTask> todoTasks)
        {
            if(todoTasks.Count > 0)
            {
                string summary = String.Empty;

                for(int i = 0; i < todoTasks.Count; i++)
                {
                    summary = (i == (todoTasks.Count - 1) ? (summary + todoTasks[i].TaskName) : (summary + $"{todoTasks[i].TaskName}, "));
                }

                return summary;
            }

            return String.Empty;
        }
    }
}
