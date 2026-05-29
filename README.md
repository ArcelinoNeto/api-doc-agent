# API Doc Agent

API Doc Agent is a backend-only Ruby on Rails API for studying third-party API documentation.

The MVP receives API documentation by URL or PDF attachment, processes it asynchronously with specialized agents, extracts endpoint candidates, and creates a structured technical study for implementation planning.

## Architecture

- Ruby on Rails API mode
- PostgreSQL as the primary database
- Redis and Sidekiq for asynchronous processing
- Active Storage prepared for PDF uploads
- RSpec for tests
- RuboCop and Brakeman for quality and security checks
- Docker and Docker Compose for local services
- GitHub Actions for CI and Docker image publishing to GHCR

## Domain

- `ApiDocument`: registered API documentation and processing status
- `AgentExecution`: audit trail for each agent run
- `ExtractedEndpoint`: endpoint candidates extracted from the documentation
- `TechnicalStudy`: generated technical study for the API

Initial agents:

- `Agents::DocumentReaderAgent`
- `Agents::EndpointExtractorAgent`
- `Agents::TechnicalStudyAgent`

## Setup

```bash
bundle install
bin/rails db:create db:migrate
```

With Docker:

```bash
docker compose up --build
```

Run Sidekiq locally:

```bash
bundle exec sidekiq
```

## Tests and Checks

```bash
bundle exec rspec
bin/rubocop
bin/brakeman --no-pager
```

## API Endpoints

Create a URL document:

```bash
curl -X POST http://localhost:3000/api/api_documents \
  -H "Content-Type: application/json" \
  -d '{"api_document":{"title":"Payments API","source_type":"url","source_url":"https://example.com/docs"}}'
```

Create a PDF document:

```bash
curl -X POST http://localhost:3000/api/api_documents \
  -F "api_document[title]=Payments API" \
  -F "api_document[source_type]=pdf" \
  -F "api_document[pdf_file]=@docs.pdf"
```

Read data:

```bash
GET /api/api_documents/:id
GET /api/api_documents/:id/status
GET /api/api_documents/:id/agent_executions
GET /api/api_documents/:id/extracted_endpoints
GET /api/api_documents/:id/technical_study
```

## Roadmap

- Add PDF text extraction.
- Integrate OpenAI API in the agent pipeline.
- Improve endpoint extraction with structured LLM output.
- Add authentication and rate limiting for public usage.
- Expand request, service, and job coverage.
