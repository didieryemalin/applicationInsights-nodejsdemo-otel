using System;
using System.Text;
using System.Net.Http;
using System.Threading.Tasks;

using Microsoft.Extensions.Logging;

using Newtonsoft.Json;

using ApplicationInsights.Nodejsdemo.TaskProcessor.Models;

namespace ApplicationInsights.Nodejsdemo.TaskProcessor.Helpers
{
    public static class EmailHelper
    {
        static readonly HttpClient client = new HttpClient();

        public static bool SendDataToEmailService(TaskNotification taskNotification, ILogger logger)
        {
            logger.LogInformation("Getting ready to send data to email service");

            string emailServiceURI = Environment.GetEnvironmentVariable("EMAIL_SERVICE_URI");

            try
            {
                var json = JsonConvert.SerializeObject(taskNotification);
                var data = new StringContent(json, Encoding.UTF8, "application/json");

                using var response = Task.Run(() => client.PostAsync(emailServiceURI, data))
                                         .ConfigureAwait(false)                     
                                         .GetAwaiter()
                                         .GetResult();

                response.EnsureSuccessStatusCode();

                return true;
            }
            catch(Exception ex)
            {
                logger.LogCritical($"Failed to send data to email service", ex);

                return false;
            }
        }
    }
}
