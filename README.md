# desktop-setup
Scripts to deploy a fresh desktop environment.

## [Pop! OS Download](https://system76.com/pop/download/?srsltid=AfmBOopceCSQ7sEyktnyPRdyNQvyLp19kw9GvyJileS4WTL-QezShkrF)
+ Start by installing the base OS and wipe everything

## Restore Steps
+ Install base dependencies for scripts
```
sudo apt-get update && sudo apt-get upgrade 
sudo apt-get install git
```
+ Install and run setup script
```
git clone https://github.com/cole-titze/desktop-setup.git
cd desktop-setup
chmod u+r+x *
source setup.sh > output.txt 2>&1
```
## [Add key to github](https://docs.github.com/en/github/authenticating-to-github/adding-a-new-ssh-key-to-your-github-account)
+ Copy contents of ~/.ssh/id_ed25519.pub to github public ssh keys in settings
+ Make sure ssh keys are working
```
cd && rm -rf desktop-setup
git clone git@github.com:coleTitze/desktop-setup.git
```
