#!/bin/bash
# On your local machine
infocmp > ghostty.terminfo
scp ghostty.terminfo root@pve:/tmp/
ssh root@pve "tic -x /tmp/ghostty.terminfo" 
