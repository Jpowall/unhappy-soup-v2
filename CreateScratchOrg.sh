#!/bin/bash
set -e

# Created by Acumen Solutions, Inc. Developers: Scott Predmore and Alex Birchfield
# Dependencies: Salesforce CLI and Git

# COMMAND: sh CreateScratchOrg.sh ID_FOR_FEATURE_BRANCH/SCRATCH_ORG

# ORDER OF OPERATIONS:
# Check out and pull target branch
# Create feature branch
# Create scratch org
# Opens new scratch org
# Deploy packages to it

packages=("force-app") #Define package that will be deployed to scratch org. For multiple packages: ("PACKAGE1" "PACKAGE2")

promptUserToDeployPackage () {

    echo -e "\nDo you want to deploy the $2 package to the newly created Scratch Org called $1:"
    echo -e "\nEnter 1 for Yes or enter 2 for No"

    select yn in "Yes" "No"; do
        case $yn in
            Yes )
                echo -e "\nDeploying $2 to $1..."
                sfdx force:source:deploy -p "$2" -u "$1";
                break;;
            No )
                break;;
        esac
    done
}

#####

echo -e "\nThis script creates a scratch org and its associated feature branch. Doing so will require the script to run several 'hard' Git commands. Ensure that any work is backed up before running this script. Do you want to continue: "
echo -e "\nEnter 1 for Yes or enter 2 for No"

select yn in "Yes" "No"; do
    case $yn in
        Yes ) break;;
        No ) echo -e "\nQuitting script..."; exit;;
    esac
done

read -p "Enter Target Branch to create feature branch off of: " TARGET_BRANCH

echo -e "\nChecking out $TARGET_BRANCH..."

git checkout -f $TARGET_BRANCH
git fetch origin
git reset --hard origin/$TARGET_BRANCH

#####

echo -e "\nDo you want to create a new Feature Branch or use an existing one?"
echo -e "\nEnter 1 for New or enter 2 for Existing"

select yn2 in "New" "Existing"; do
    case $yn2 in
        New )
            echo -e "\nCreating a Feature Branch off of $TARGET_BRANCH called $1..."
            git checkout -b feature/"$1"
            git reset --hard
            break;;
        Existing )
            echo -e "\nUsing existing Feature Branch called $1..."
            git checkout feature/"$1"
            git reset --hard
            break;;
    esac
done


#####

echo -e "\nDo you want to create a new Scratch Org or use an existing one?"
echo -e "\nEnter 1 for New or enter 2 for Existing"

select yn3 in "New" "Existing"; do
    case $yn3 in
        New )
            echo -e "\nCreating Scratch Org called $1..."
            sfdx force:org:create -f config/project-scratch-def.json -d 15 -w 5 -a "$1" -s
            break;;
        Existing )
            echo -e "\nUsing existing Scratch Org called $1..."
            break;;
    esac
done

#####

echo -e "\nOpening the newly created Scratch Org called $1...";
sfdx force:org:open -u "$1";

#####

echo -e "\nBegin package deployment to the newly created Scratch Org called $1..."

for package in "${packages[@]}"; do
    promptUserToDeployPackage "$1" "$package"
done

#####

echo -e "\nScratch Org Creation and Package Deployments are complete."
