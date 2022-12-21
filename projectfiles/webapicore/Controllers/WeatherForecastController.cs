using Microsoft.AspNetCore.Mvc;
using WeatherForecast.Models;
using Microsoft.EntityFrameworkCore;

namespace webapicore.Controllers;

[ApiController]
[Route("[controller]")]
public class WeatherForecastController : ControllerBase
{
    private dbContext _dbContext;
    private static readonly string[] Summaries = new[]
    {
        "Freezing", "Bracing", "Chilly", "Cool", "Mild", "Warm", "Balmy", "Hot", "Sweltering", "Scorching"
    };

    private readonly ILogger<WeatherForecastController> _logger;

    public WeatherForecastController(ILogger<WeatherForecastController> logger, dbContext context)
    {
        _dbContext = context;
        _logger = logger;
    }

  [HttpGet(Name = "GetWeatherForecast")]
    public IEnumerable<WeatherForecast> Get()
    {
        
        return Enumerable.Range(1, 5).Select(index => new WeatherForecast
        {
           Date = DateTime.Now.AddDays(index),
          TemperatureC = Random.Shared.Next(-20, 55),
           Summary = Summaries[Random.Shared.Next(Summaries.Length)]
        })
        .ToArray();
    }

 
}
