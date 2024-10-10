Here’s a README that explains the Health Check process, its functionality, prerequisites, and other necessary information:

---

# Health Check Promotion/Rollback Workflow

This workflow is designed to automate the **promotion** or **rollback** of deployments across environments (Dev and Prod) with integrated health checks to ensure smooth transitions. It also manages OAuth token acquisition and logs key actions and outcomes in a PostgreSQL database.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Environment Variables and Secrets](#environment-variables-and-secrets)
- [Workflow Execution](#workflow-execution)
- [How It Works](#how-it-works)
  - [OAuth Token Acquisition](#oauth-token-acquisition)
  - [Database Operations](#database-operations)
  - [Health Check](#health-check)
  - [Promotion/Rollback API](#promotionrollback-api)
- [Post-Deployment Actions](#post-deployment-actions)
- [Additional Notes](#additional-notes)

## Overview

The **Health Check Promotion/Rollback Workflow** ensures reliable promotion and rollback of site versions in both Dev and Prod environments. This workflow performs the following tasks:

1. Retrieves the last **sequence number** from the database.
2. Acquires an **OAuth token** for authentication.
3. Based on the operation (promote/rollback), it:
   - For **promotion**, pushes a new site version.
   - For **rollback**, identifies and reverts to the last stable version.
4. Initiates the promotion/rollback process via an **API request**.
5. Performs a **health check** to validate the stability of the deployment.
6. Updates the database with the deployment status.

## Prerequisites

### Required Tools

- **GitHub Actions** for CI/CD automation.
- **PostgreSQL**: Ensure you have a PostgreSQL database set up to store sequence numbers and deployment logs.
- **OAuth API**: The workflow needs access to an API to acquire OAuth tokens for authorization.
- **Deployment API**: The workflow requires APIs to trigger the start of deployments and fetch deployment status.
  
### Secrets

To use this workflow, ensure the following **secrets** are configured in your GitHub repository:

| Secret Name               | Description                                                       |
| ------------------------- | ----------------------------------------------------------------- |
| `DB_HOST`                 | Hostname of the PostgreSQL server.                                |
| `DB_USER`                 | PostgreSQL username.                                              |
| `DB_PASSWORD`             | PostgreSQL password.                                              |
| `DB_NAME`                 | Name of the PostgreSQL database.                                  |
| `DB_PORT`                 | Port for the PostgreSQL server.                                   |
| `OAUTH_CLIENT_ID_DEV`      | OAuth client ID for Dev environment.                              |
| `OAUTH_CLIENT_SECRET_DEV`  | OAuth client secret for Dev environment.                          |
| `OAUTH_CLIENT_ID_PROD`     | OAuth client ID for Prod environment.                             |
| `OAUTH_CLIENT_SECRET_PROD` | OAuth client secret for Prod environment.                         |

### Inputs for the Workflow

These inputs should be passed when invoking the workflow:

| Input Name          | Type   | Required | Description                                                                 |
| ------------------- | ------ | -------- | --------------------------------------------------------------------------- |
| `site`              | String | Yes      | The name of the site to be promoted/rolled back.                             |
| `branch`            | String | Yes      | The environment branch (`dev`, `prod`) where the operation is to be executed.|
| `mode`              | String | No       | Additional mode information (optional).                                      |
| `requestor`         | String | Yes      | The user who initiated the operation.                                        |
| `operation`         | String | Yes      | Whether to `promote` or `rollback`.                                          |
| `site_registration_id` | String | Yes   | Registration ID for the site being acted upon.                               |

## Environment Variables and Secrets

This workflow relies on environment variables that are configured at runtime, such as database credentials and OAuth client details.

1. **Database Variables:**
   - These variables are passed as environment secrets to access PostgreSQL for retrieving and updating deployment sequences.

2. **OAuth Secrets:**
   - The workflow fetches OAuth tokens for both Dev and Prod environments using different secrets (`OAUTH_CLIENT_ID_DEV`, `OAUTH_CLIENT_SECRET_DEV` for Dev and similar ones for Prod).

3. **API URLs:**
   - Promotion status and start URLs are determined based on the target environment (`dev` or `prod`).

## Workflow Execution

To execute this workflow, call it from another workflow using the `workflow_call` event, passing the necessary inputs:

```yaml
jobs:
  call_promotion_rollback:
    uses: ./.github/workflows/promotion_rollback.yml
    with:
      site: "example_site"
      branch: "dev"
      operation: "promote"
      requestor: "username"
      site_registration_id: "12345"
```

This will trigger the promotion or rollback operation on the specified site and branch.

## How It Works

### OAuth Token Acquisition

The workflow acquires an OAuth token required for making authorized API calls. Depending on the environment (Dev or Prod), it uses different client IDs and secrets to retrieve the token. The token is stored as an environment variable and used in subsequent API requests.

### Database Operations

The workflow interacts with a PostgreSQL database to retrieve and store deployment logs. It fetches the latest sequence number and logs the outcome of each deployment, either as `SUCCESS` or `FAILURE`.

- **Retrieve Sequence Number:** The workflow fetches the current sequence number before initiating any operation.
- **Update Sequence Number:** Once the operation is completed, the workflow updates the database with the result of the promotion or rollback.

### Health Check

After a promotion or rollback is initiated, the workflow performs a health check to ensure that the site is stable. It:

1. **Checks the Promotion Status**: Calls an API to get the current promotion status for the site.
2. **Waits for Site to Stabilize**: Ensures a wait time for the site to stabilize after deployment (e.g., 5 minutes).
3. **Logs the Health Check Result**: If the site is healthy, the deployment is marked as successful; otherwise, it's marked as failed.

### Promotion/Rollback API

The workflow makes API calls to either promote or roll back a site version:

- **Promotion:** Promotes the site to a new version based on the environment.
- **Rollback:** Rolls back to the last stable version.

The API responses, including version and status, are stored and used to update the deployment logs.

## Post-Deployment Actions

Once the promotion or rollback is complete, the workflow updates the PostgreSQL database with the results. It records the final status (`SUCCESS` or `FAILURE`) and updates the comments and timestamps accordingly.

## Additional Notes

- Ensure that the **OAuth credentials** and **API URLs** are correctly configured for each environment.
- **Database Connection:** Make sure your database is accessible and credentials are correctly set up for the workflow to interact with it.
- The health check currently waits for **5 minutes** before finalizing the deployment. This can be adjusted based on your system’s needs.

--- 

This README should cover all the necessary aspects of the health check process and related promotion/rollback workflow. Let me know if anything needs adjustment or if you'd like to add more details!
