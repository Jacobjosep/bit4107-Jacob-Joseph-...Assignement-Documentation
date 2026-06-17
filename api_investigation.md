# Week 6 Task 2: API Investigation

## API Name: JSONPlaceholder API
**URL:** https://jsonplaceholder.typicode.com

### Purpose
Provides fake REST API data for testing and prototyping mobile applications.

### API Endpoints
| Endpoint | Method | Description |
|----------|--------|-------------|
| /posts | GET | Get all posts |
| /posts/1 | GET | Get specific post |
| /posts | POST | Create new post |
| /posts/1 | PUT | Update post |
| /posts/1 | DELETE | Delete post |

### GET Request Example
GET https://jsonplaceholder.typicode.com/posts/1

### Expected Response
{
  "userId": 1,
  "id": 1,
  "title": "sunt aut facere repellat provident occaecati excepturi optio reprehenderit",
  "body": "quia et suscipit suscipit recusandae consequuntur expedita et cum reprehenderit"
}

### Alternative APIs for Education:
1. OpenWeatherMap API - Weather data
2. REST Countries API - Country information
3. GitHub API - Repository data
