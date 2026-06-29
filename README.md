# my-tailscale-auto-build-script NO SUDO
*this is the same as the other auto build repo. this one just doesnt need sudo. i made this version for my proxmox server


# to do's before running this:
        Enable tagging and create the apropriate tags
        Enable exit node advertising
        Enable API Access
        Allow ssh (optional)
        customize your tailnet name 
        
        
# You'll need to generate your own auth key and api key for your tailnet.

to do this:
        1. Go to your tailnet admin console
        2. Go to settings
        3. Click "keys" in the personal settings tab
        4. open your notes app to copy the keys to
        5. generate an Auth key and copy it in the notepad
        6. generate an api key and paste it in the notepad


this took afew tries to get right, but here's all in one script:
  
          export AUTH_KEY="your AUTH key"
          export API_KEY="your API key"
          
          curl -fsSL https://raw.githubusercontent.com/sneakysniper12/my-tailscale-auto-build-script-no-sudo/main/install-tailscale-no-sudo.sh | sudo AUTH_KEY="$AUTH_KEY" API_KEY="$API_KEY" bash


It handles:

installation, configuration, security, network routing, tagging, approval, and naming, All automatically!!



# COOL FEATURES ABOUT THIS SCRIPT:

1. installs tailscale
2. automatically sets up the device as an Exit Node
3. auto aproval for the exit node
4. automatically logs in. no need for a browser
5. auto adds tags to the devices for better categorization
6. auto generates a name for the exit node based on location
7. duplicate name prevention
8. automatic system updates
9. enables tailscale ssh






