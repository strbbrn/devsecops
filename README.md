## API Promotion/Rollback Workflow

This workflow automates the process of promoting or rolling back an application version across different environments (`stage` or `prod`). The process involves interacting with a PostgreSQL database and making HTTP requests to external APIs for promotion/rollback actions.

### Prerequisites

Before using this workflow, ensure the following prerequisites are met:

1. **Self-Hosted Runner**: This workflow uses a self-hosted runner. Make sure it is configured and running in your environment.
2. **Secrets Configuration**: The following secrets should be added to the repository settings in GitHub:
   - `DB_HOST`: The host address of your PostgreSQL database.
   - `DB_USER`: The username for your PostgreSQL database.
   - `DB_PASSWORD`: The password for your PostgreSQL database.
   - `DB_NAME`: The name of your PostgreSQL database.
   - `DB_PORT`: The port your PostgreSQL database is running on.
   - `OAUTH_CLIENT_ID`: The client ID for OAuth authentication with the external API.
   - `OAUTH_CLIENT_SECRET`: The client secret for OAuth authentication with the external API.
   
3. **PostgreSQL Setup**: Ensure that the database and necessary tables are created, and they contain the following fields:
   - `seqno`: Sequence number to track deployments.
   - `rgs_id`: Site registration ID.
   - `site_action_cd`: Action code (e.g., `PROMOTE_STAGE`, `PROMOTE_PRODUCTION`).
   - `requestor`: The person initiating the action.
   - Other required fields as specified in the `INSERT` and `UPDATE` statements within the workflow.

4. **External API**: Ensure that the external API endpoint for promotion/rollback is functional and that you have appropriate credentials for it.

### Files

- **Workflow File (`.github/workflows/promotion.yml`)**: This file defines the workflow for promoting or rolling back versions based on branch and user inputs.
- **`db_operations.py`**: A Python script that handles all the database operations such as retrieving the last sequence number, inserting new records, and updating existing records.

### How to Use

1. **Trigger the Workflow**: The workflow is triggered using the `workflow_call` event. It requires the following inputs:
   - `site`: The name of the site where the deployment is happening.
   - `branch`: The target branch for deployment (`stage` or `prod`).
   - `mode`: Optional. Can be used to pass custom deployment modes.
   - `requestor`: The person or system initiating the workflow.
   - `operation`: The action to perform, either `promote` or `rollback`.
   - `site_registration_id`: The registration ID of the site to be deployed.

2. **Install Dependencies**: The workflow installs the PostgreSQL client on the self-hosted runner to enable database operations.

3. **Database Sequence Number Retrieval**: The workflow retrieves the previous sequence number from the database using the Python script, stores it in an environment variable, and prints it for reference.

4. **Insert New Record**: Based on the inputs, the workflow inserts a new record into the database with the promotion/rollback details and retrieves the new sequence number.

5. **OAuth Authentication**: The workflow obtains an OAuth access token required for making API calls to promote or rollback the version.

6. **Version Determination**: Depending on the `operation` input (`promote` or `rollback`), the workflow either promotes a new version or rolls back to a previous valid version.

7. **Promotion/Rollback API Call**: The workflow calls an external API to initiate the promotion or rollback process.

8. **Database Update**: After the promotion/rollback process completes, the workflow updates the database with the deployment status (`SUCCESS` or `FAILURE`).

9. **Final Output**: The workflow logs the sequence number, promotion/rollback status, and other relevant details.

### Example Usage

To trigger this workflow, create a reusable workflow or trigger it via another workflow with the following parameters:

```yaml
jobs:
  promote:
    uses: your-repo/your-project/.github/workflows/promotion.yml@main
    with:
      site: "your-site-name"
      branch: "stage"
      mode: "auto"
      requestor: "deployer"
      operation: "promote"
      site_registration_id: "123456"
```

### Process Overview

1. The workflow begins by installing necessary dependencies and setting up environment variables.
2. The `db_operations.py` script is used to interact with the database for retrieving the last sequence number, inserting a new sequence number for the current promotion/rollback, and updating the deployment status.
3. The workflow retrieves an OAuth token and calls the external API to promote or rollback the application version based on the inputs provided.
4. After the promotion/rollback operation, the database is updated with the deployment result, and the workflow outputs the final status and logs.

### Workflow Inputs

- `site`: The target site for the promotion or rollback.
- `branch`: The branch/environment to promote or rollback (e.g., `stage`, `prod`).
- `mode`: Optional. Used to specify custom deployment modes.
- `requestor`: The person or system initiating the operation.
- `operation`: The operation to perform (`promote` or `rollback`).
- `site_registration_id`: The registration ID for the site being promoted or rolled back.

### Environment Variables

These variables are set via GitHub secrets:

- `DB_HOST`, `DB_USER`, `DB_PASSWORD`, `DB_NAME`, `DB_PORT`: Database credentials for connecting to PostgreSQL.
- `OAUTH_CLIENT_ID`, `OAUTH_CLIENT_SECRET`: Credentials for obtaining an OAuth token.

### Logging and Outputs

- Sequence numbers are logged throughout the workflow.
- The status of the promotion/rollback operation (`SUCCESS` or `FAILURE`) is logged and stored in the database.
- The workflow uses environment variables (`SEQNO`, `ACCESS_TOKEN`, `VERSION`, etc.) to manage and track the progress of operations. 

### Conclusion

This workflow automates the complex process of promoting or rolling back an application version, interacting with both a PostgreSQL database and external APIs. By using GitHub Actions to manage these tasks, the workflow ensures repeatability, security, and efficiency.
