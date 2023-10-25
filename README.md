# Wazuh Installation Script

This script automates the installation of Wazuh, an open-source security monitoring platform. It's designed to set up the Wazuh manager (server), Wazuh indexer, and Wazuh dashboard. The script is created by Knippin ICT and can be used to simplify the Wazuh installation process.

## Prerequisites

- A clean installation of a compatible Linux distribution (e.g., CentOS, Ubuntu, Debian) on the target servers.

## Instructions

1. **Clone or Download the Script**

    You can clone this repository or download the script to your local machine.

2. **Run the Script**

    Make the script executable:

    ```bash
    chmod +x wazuh-install-script.sh
    ```

    Run the script:

    ```bash
    ./wazuh-install-script.sh
    ```

3. **Follow the Prompts**

    - The script will display LAN IP addresses for all available network interfaces.
    - You'll be prompted to enter the LAN IP addresses for the dashboard, indexer, and Wazuh manager.
    - The script will remove the existing `config.yml`, download the new one, and proceed with the installation using your provided IP addresses.

4. **Access the Wazuh Web Interface**

    After a successful installation, you can access the Wazuh dashboard by opening a web browser and navigating to the IP address of the server where you installed the Wazuh dashboard, using the appropriate port (usually 5601). Log in with the default credentials or the ones you configured during the installation process.

## Additional Notes

- If you encounter any issues or have questions about Wazuh, please refer to the official [Wazuh documentation](https://documentation.wazuh.com/).
- This script is for educational purposes and may require modifications to suit your specific environment and requirements.

## License

This script is provided under the [MIT License](LICENSE).
