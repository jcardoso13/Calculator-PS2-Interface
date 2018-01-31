# README #

This README would normally document whatever steps are necessary to get your application up and running.

### What is this repository for? ###

* Quick summary
* Version
* [Learn Markdown](https://bitbucket.org/tutorials/markdowndemo)

### How do I get set up? ###

* Summary of set up

Install Python (2.7.9 works)

Install Icarus Verilog v10_1_1 (http://iverilog.icarus.com)

Set the following environment variables:

export XCTRL_HOME=/path/to/ipb-xctrl/repo
export PATH=$PATH:/$XCTRL_HOME/python_src

* Configuration
* Dependencies
* Database configuration
* How to run tests

cd tests
make -C test_dir 

* Deployment instructions

### Contribution guidelines ###

* Writing tests

cd tests
cp -r existing_test new_test
cd new_test
mv existing_test.va new_test.va
mv existing_test.json new_test.json

add/remove verilog project files
edit xmem_map.v 
edit new_test.json
edit Makefile 


* Code review
* Other guidelines

### Who do I talk to? ###

* Repo owner or admin
* Other community or team contact