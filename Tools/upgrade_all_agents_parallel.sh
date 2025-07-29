#!/bin/bash
# upgrade_all_agents_parallel.sh
#
# This script upgrades all Wazuh agents in parallel using xargs.
# It lists the agents, displays them in a table format, and then asks for user confirmation before proceeding.
#
# Usage:
#   ./upgrade_all_agents_xargs.sh [NUM_JOBS]
#
# Example:
#   ./upgrade_all_agents_xargs.sh 10
#   (Defaults to 5 parallel jobs if not provided)

# Set the number of parallel jobs (default: 5)
NUM_JOBS="${1:-5}"

echo "Starting upgrade of all agents with $NUM_JOBS parallel jobs..."
echo ""

# Get the list of agent IDs using `/var/ossec/bin/agent_upgrade -l`
# Skip the header line and extract the first column containing the agent ID.
agent_ids=$( /var/ossec/bin/agent_upgrade -l | awk 'NR > 1 {print $1}' )

if [ -z "$agent_ids" ]; then
    echo "No agents found. Exiting."
    exit 1
fi

# Display the list of agent IDs in a table format (4 agents per row)
echo "Agents to upgrade (table format):"
echo "$agent_ids" | xargs -n4 | column -t
echo ""

# Ask for user confirmation before proceeding
read -p "Do you want to proceed with upgrading these agents? (Y/n): " response
# Default to "Y" if no input is provided
response=${response:-Y}
if [[ ! $response =~ ^[Yy] ]]; then
    echo "Upgrade aborted by user."
    exit 0
fi

echo ""
echo "Upgrading agents..."

# Use xargs to run the upgrade command in parallel for each agent.
# The command: `/var/ossec/bin/agent_upgrade -a {}` is executed for each agent ID.
echo "$agent_ids" | xargs -P "$NUM_JOBS" -I {} /var/ossec/bin/agent_upgrade -a {}

echo ""
echo "Upgrade commands have been issued to all agents."
