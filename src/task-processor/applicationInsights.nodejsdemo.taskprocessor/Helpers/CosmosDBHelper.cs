using System;

using Microsoft.Extensions.Logging;
using Microsoft.ApplicationInsights;
using Microsoft.ApplicationInsights.DataContracts;

using MongoDB.Driver;

using ApplicationInsights.Nodejsdemo.TaskProcessor.Models;

namespace ApplicationInsights.Nodejsdemo.TaskProcessor.Helpers
{
    public static class CosmosDBHelper
    {
        private static MongoClient client;
        private static IMongoCollection<TaskNotification> container;

        public static void Setup()
        {
            // Retrieve cosmos settings
            string cosmosdb_connection_string = Environment.GetEnvironmentVariable("COSMOS_DB_CONNECTION_STRING");
            string cosmosdb_database_name = Environment.GetEnvironmentVariable("COSMOS_DB_DATABASE_NAME");
            string cosmosdb_container_name = Environment.GetEnvironmentVariable("COSMOS_DB_CONTAINER_NAME");

            // Initialize CosmosDB Client and get container reference
            client = new MongoClient(cosmosdb_connection_string);
            var db = client.GetDatabase(cosmosdb_database_name);
            container = db.GetCollection<TaskNotification>(cosmosdb_container_name);
        }

        public static void CreateTaskNotification(TaskNotification taskNotification, TelemetryClient telemetryClient, ILogger logger)
        {
            DateTime start = DateTime.UtcNow;

            logger.LogInformation("Adding email notification record to database");

            try
            {
                container.InsertOne(taskNotification);

                var dependency = new DependencyTelemetry
                {
                    Name = "Record Task Notification",
                    Target = "Email Notifications DB",
                    Data = $"db.email_notifications.insert({taskNotification})",
                    Type = "Azure DocumentDB",
                    Timestamp = start,
                    Duration = DateTime.UtcNow - start,
                    Success = true
                };

                dependency.Context.User.Id = taskNotification.EmailAddress;
                telemetryClient.TrackDependency(dependency);
            }
            catch(Exception ex)
            {
                logger.LogCritical($"Failed to email tasks to {taskNotification.EmailAddress}", ex);
            }

            logger.LogInformation("Done adding notification record to database");
        }

    }
}