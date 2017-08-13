# Introduction

The purpose of this document is to provide you with:

* minimal knowledge of Go; 

* a view of developing chaincode from coding (not abstract) perspective. 

Hopefully following from what you have learnt here, you will have sufficient knowledge to move on to developing real-world chaincode.

This document is intended for anyone with programming experience but having no or very little experience of Go and chaincode development. You are expected to be familiar with the concept of compilation and packaging as Go is a compiled, not scripting, langauge. 

If you are already an experience Go developer please refer to [hyperledger fabric documentation for advance instruction](http://hyperledger-fabric.readthedocs.io/en/latest/chaincode4ade.html). This would not be the document for you.

In this document, you will learn to:

* [Setup for chaincode development](#setupDevEnv)

* [Minimal Go for chaincode development](#learnGo)

* [Write chaincodes](#goForChaincode)

* [Hyperledger fabric for chaincode development](#fabricForDevelopment)

* [Debugging chaincode](#debugChaincode)

* [Moving on](#movingOn)

# <a name="setupDevEnv">Setup for chaincode development</a>

Setting up a development environment for chaincode projects is no different from setting up for other non chaincode Go projects. 

For a basic (terminal and command-line) environment for chaincode development, please follow the following steps:

1. Install [Go tools](http://golang.org/dl).

    * for macOS, we recommend installing via [homebrew](http://brew.sh/);

    * for other platforms please refer to [installation guide](https://golang.org/doc/install).

    Additional notes for this setp:

    * Please also ensure that you also install C++ compiler. Refer to your respective platform documentation for instructions.

    * On Ubuntu you may also need to install a library call `ltdl` (please refer to `apt-get install ltdl-dev`).

1. Set the environmental variable `GOPATH` to a reference a directory to host your Go source codes and binaries (i.e. Go workspace). For example,
    
    ```
    export GOPATH=$HOME/go-projects
    ```

1. Navigate to the `$GOPATH` directory and install a Go application call [Govendor](https://github.com/kardianos/govendor) by executing this command:
    
    ```
    go get -u github.com/kardianos/govendor
    ```

    At the completion of the command, you will find in `$GOPATH` three directories:

    ```
    drwxr-xr-x  3 <userid>  <groupid>  102  3 Feb 15:44 bin
    drwxr-xr-x  3 <userid>  <groupid>  102  3 Feb 15:44 pkg
    drwxr-xr-x  3 <userid>  <groupid>  102  3 Feb 15:44 src
    ```

    This structure is dictated by Go tooling and will be your primary workspace for organising your chaincodes and and other dependencies such as third parties codes, tooling extensions, etc.

    In the context of chaincode development, you will be working mainly with Go sources. Hence, you only need to concern yourself with organising stuff within `src` directory.

    Additional notes for this step:

    * This step is not strictly needed. You could have create the workspace directories manually.

    * [Govendor](https://github.com/kardianos/govendor) is a package or dependency management tool. It is one of many tools you can use to manage Go dependencies. The choice of `Govendor` is purely based on familarity. You could elect to install [other tools](https://github.com/golang/go/wiki/PackageManagementTools)).

1. Add the `$GOPATH/bin` to your `PATH` environmental variable. For example:

    ```
    export PATH=$GOPATH/bin:$PATH
    ```

    `$GOPATH/bin` is a directory for binaries generated from Go compilations. Some of these binaries may be used to extend the functionalities of Go tooling or any other support tools. If you are using [Visual Studio Code](https://code.visualstudio.com/), you will find extensions to the editor such as code completion or syntax highlighting, served from this directory.

1. Get the hyperledger fabric dependencies (the framework to support your chaincode developmemnt) by issuing the following commands:

    ```
    go get -d github.com/hyperledger/fabric
    ```

    At the completion of this command, you will see this message:

    ```
    package github.com/hyperledger/fabric: no buildable Go source files in /Users/blockchain/workspace/misc/src/github.com/hyperledger/fabric
    ```
    
    There is no need to worry. Go tooling typically pull source code and then tries to build a binary but in this case the hyperledger fabric dependencies have nothing to be built.

    If you wish to ensure that the dependencies have been pulled down, simply navigate to `$GOPATH/src/github.com` and if you see the directory `hyperledger` it means that dependencies have been downloaded. 

# <a name="learnGoLang">Minimal Go for Chaincode</a>

To learn more about Go progranmning language, please refer to these resources:

* [Go playground](https://play.golang.org/) - This a a web-base development environment where you can learn to code in Go without the need to setup a local development environment.

* [Go by example](https://gobyexample.com/) - This is a series of code snippets demonstrating features of Go by theme.

To create a minimal chaincode focus your learning on these areas 

* [data types](https://gobyexample.com/variables);

* [functions](https://gobyexample.com/functions);

* [structs](https://gobyexample.com/structs);

* [interfaces](https://gobyexample.com/interfaces).

You will also need to be aware that all your Go codes (and chaincodes) have to be organised around `$GOPATH/src` directory. For example, here is a hypothetical structure:

```
    $GOPATH/src
        git.ng.bluemix.net/project/repo
            cmd
                main.go
            helper
                math.go
        github/spf13/corbra // Third parties code
            ....
```

Organise your code and dependencies to reflect the way codes would be stored in a typical Git-like repository. Please refer to the official documentation about [code organisation](https://golang.org/doc/code.html#Organization).

# <a name="goForChaincode">Writing chaincode</a> 

In this section you will learn to:

* [write the smallest unit of executable chaincode](#smallestchaincode);

* [organise your chaincode project](#organiseChaincode).

### <a name="smallestchaincode">Smallest unit of executable chaincode</a>

A minimal executable Go code is this:

```
package main

import "fmt"

func main() {
	fmt.Printf("Hello, world.\n")
}

```

To compile and execute this code all you need to do is to issue the command `go run`. It will run in your macOS, Linux, Windows or any compatible platform.

In the case of chaincode, the smallest unit of executable code is this:

```
package main

import (
    "fmt"

    "github.com/hyperledger/fabric/core/chaincode/shim"
    pb "github.com/hyperledger/fabric/protos/peer" 
)

type SimpleChaincode struct{}

func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
    return shim.Success([]byte("Init called"))
}

func (t *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
    return shim.Success([]byte("Invoke called"))
}

func main() {
    err := shim.Start(new(SimpleChaincode))
    if err != nil {
        fmt.Printf("Error: %s", err)
    }
}
```

Place your code in the file `chaincode.go` under the appropriate part of you Go workspace for example, `$GOPATH/src/github.com/user/repo/chaincode.go`.

To get a sense of whether the code is workable, navigate to the directory containing your main chaincode file and execute `go run` command. example

```
cd $GOPATH/src/github.com/user/repo/
go run chaincode.go
```

You will see the following output:

```
<Date> <Timestamp> <Timezone> [shim] SetupChaincodeLogging -> INFO 001 Chaincode log level not provided; defaulting to: INFO
<Date> <Timestamp> <Timezone> [shim] getPeerAddress -> CRIT 002 peer.address not configured, can't connect to peer
exit status 1
```

This simply indicates that the chaincode has been successfully compiled and your code has been executed. However, there is no running hyperledger fabric infastructure to interact with so you see this error message.

Unlike normal Go program, you can't just compile and run chaincode in macOS, Linux, Windows, etc. Instead you will need to bundle the code and deploy it to a running hyperledger fabric platform known as fabric peer (see [architecture](http://hyperledger-fabric.readthedocs.io/en/latest/arch-deep-dive.html#system-architecture) for detailed explanation). 

A fabric peer typically runs from a Docker container. Although you could "natively" deploy a peer as part of a component of macOS, Linux, Windows, etc., it is beyond the scope of this document. We'll only focus on the Docker version.

<hr>

**Note**

* In the `import` clause of your chaincode, you'll see this `github.com/hyperledger/fabric/core/chaincode/shim`, which is a hyperledger fabric component (i.e. think library if you are C++ programmer).

* The `import` is derived from `$GOPATH/src/github.com/hyperledger/fabric`.

<hr>

### <a name="organiseChaincode">Organising your chaincode project</a>

It is extremely unusual to create a chaincode from a single file. 

You may want to re-use aspects of a Go code developed by third parties and/or separate out your functional from non-functional (e.g. string formatter) dependencies. Hence, you may want to distribute chaincode in different files and/or directories.

If you were writing Go project you would organise your dependencies this way:

```
$GOPATH/
    src/
        github.com/anotheruser/repo/
            anothersrc.go
        github.com/user/repo/
            mypkg/
                mysrc1.go
                mysrc2.go
            cmd/mycmd/
                main.go
```

This is a sufficient structure to compile and run code on macOS, Linux, Windows, etc.

In the case of chaincode development, this structure will not work. You will need to organise all your dependencies under one root directory and then deploy the root directory to a fabric peer. 

Here is an example of a hypothetical chaincode project:

```
$GOPATH/
    src/
        github.com/user/repo/
            mychaincode/
                util/
                    mymaths.go
                chaincode.go
                vendor/
                    github.com/anotheruser/repo
                        anothersrc1.go
                        anothersrc2.go
                    vendor.json
```
In this example:

* `mychaincode` directory is the root directory encapsulating your entire chaincode artifacts including dependencies;

* `util` is an example custom directory created by you to distribute your chaincode;

* `vendor` is a special directory (with a file `vendor.json`) typically to package dependencies not located at the chaincode root or third parties (see detailed explanations of the use of [vendor folder](https://blog.gopheracademy.com/advent-2015/vendor-folder/)).

You can manually create and provision the `vendor` directory but using tools makes it easier. As per the [setup step](#setupDevEnv), let's use `Govendor` to `vendor` your dependencies: 

1. Navigate to `$GOPATH/src/github.com/user/repo/mychaincode` and execute this command:

    ```
    govendor init
    ```

   You should see a directory call `vendor`.

1. In the directory `vendor` add the following line to `vendor.json`:

    ```
    "ignore": "test github.com/hyperledger/fabric"
    ```

    This line tells `govendor` not to include `github.com/hyperledger/fabric` and test dependencies. You don't need to include hyperledger fabric dependency because it is part of the fabric peer infrastructure.

1. We are going to `vendor` a third party dependency `github.com/antoheruser/repo` by issuing this command:

    ```
    govendor fetch github.com/anotheruser/repo
    ```

    If no error you will see the dependencies stored in `vendor` directory.

<hr>

**Note:**

* What if I wish to re-use another project that is outside the chaincode root directory but in the Go workspace?

* For example, this is my code structure:

    ```
    $GOPATH/
        src/
            github.com/user/another-repo/
                support/
                    superduper-support.go
                superduper-algo.go
            github.com/user/repo/
                mychaincode/
                    chaincode.go
                    util/
                        mymaths.go
                    vendor/
                        github.com/user/another-repo
                            support/
                                superduper-support.go
                            superduper-algo.go
                        vendor.json
    ```

    I wish to vendor `github.com/user/another-repo/` in `mychaincode` directory.
    
    It is beyond the scope of this document but you could consider using the command `govendor add +external`. This will pull all the artefacts in `$GOPATH` into `vendor`. Please refer to [Govendor documentation](github.com/user/another-repo/) for details.

<hr>

# <a name="fabricForDevelopment">Hyperledger fabric for chaincode development</a>

In this section, you will learn:

* [about roles of the components of a minimal fabric](#minimalFabric);

* [setup a minimal hyperledger fabric infrastructure](#setupMinimalFabric)

### <a name="minimalFabric">Roles of minimal fabric component</a>

In order to see your chaincode in action, you'll need to setup fabric infrastructure and deploy your chaincode there. A full featured running fabric infrastructure has many components.

For the purpose of document, we'll focus on the most minimal fabric infrastructure to enable you to probe a running chaincode. 

We'll be using Docker. If you have not setup Docker please refer to [documentation](https://www.docker.com/community-edition#/download). You can see an example of a minimal infrastructure configuration [here](./fabric/docker-compose.yml). 

The docker containers that comprise a minimal fabric infastructure are: 

* `orderer.example.com` where it's role is beyond the scope of document and for simplicity just think of it as a manager for the next component;

* `peer0.org1.example.com` is the container that will be responsible for spinning up another container to support your running chaincode;

* `cli` is a command line container that you use to interact with `peer0.org1.example.com`.

<hr>

**NOTE**

This is not an setup for use in, or representative of, any mission critical blockchain use case. This is only to support a simple chaincode development process by enabling developer to get feedback from a running chaincode.

There are also other aspects of the hyperledger fabric infrastructure that is beyond the scope of this document. These are cryptography components, which need not concern you for current discussion.

For detailed descriptions of the roles of hyperledger fabric components, please refer to hyperledger fabric [architecture explained](http://hyperledger-fabric.readthedocs.io/en/latest/arch-deep-dive.html).

<hr>

### <a name="setupMinimalFabric">Setup a minimal hyperledger fabric</a>

You will find a set of scripts located [here](./fabric) to help you:

* [configure docker containers](./fabric/docker-compose.yml);

* membership polcy assets (i.e. [configtx.yml](./fabric/configtx.yml) and [crypto config](./fabric/crypto-config.yaml));

* [install, instantiate and invoke chaincode](./fabric/scripts);

* [manage fabric operations](./fabric/fabricOps.sh).

In the case of [fabricOps.sh](.fabric/fabricOps.sh), you use it to:

| Command | Action | Comments |
|---|---|---|
| `fabricOps.sh start` | Start a running fabric infrastructure | In order for `peer0.org1.example.com` to work with `orderer.example.com` they must be managed within the context the same membership policy. The policy assets are generated based on [configtx.yml](./fabric/configtx.yml) and [crypto config](./fabric/crypto-config.yaml).<br><br>When you execute this fabric operation, a share member policy is generated and followed by docker contanters. |
| `fabricOps.sh status` | Check status of docker containers | This operation is used to check the status of your docker containers.<br><br>This example shows all the relevant containers are running properly: <code><b><br>dev-peer0.org1.example.com-mycc-1.0: Up 24 seconds<br>peer0.org1.example.com: Up 26 minutes<br>cli: Up 26 minutes<br>orderer.example.com: Up 26 minutes</code></b> |
| `fabricOps.sh clean` | Reset the fabric infrastructure | This operation removes membership and docker artefacts.<br><br> **NOTES:**<br> This will only remove docker containers and images that are responsible for running chaincodes (typically with a name containing `dev-` prefix). It should not impact any docker containers that you may already have in operation but I can't be guaranteed. If you have concerned please modify `fabricOps.sh` accordingly. |
| `fabricOps.sh cli` | This operation gives you access to fabric `cli` | You will be given access to `cli`'s own terminal. From there you can then execute chaincode related operations which we'll discussion on the next sections |

<hr>

**Windows**

There is currently no out-of-the-box support for Windows platform. The script `fabricOps.sh` only supports macOS or Linux.

<hr>

# <a name="debugChaincode">Debugging chaincode</a>

In this section, you will learn to execute a simple chaincode and debug your chaincode using the infrastructure shown above.

To help you get going with your learning, please follow the following steps:

1. Executing this command `go get github.com/hlf-go/writing-chaincode` (assuming you have already completed [this setup](setupDevEnv)).

    You will find this in your Go workspace:

    ```
    $GOPATH/src/github.com/hlf-go/
        writing-chaincode/
            chaincodes/
                myfirstchaincode
                    chaincode.go
            fabric/
                scripts/
                    myfirstchaincode.sh
                configtx.yml
                crypto-config.yaml
                docker-compose.yml
                fabricOps.sh
            .gitignore
            README.md
    ```

    This is a pre-configured chaincode development framework.

1. Navigate to `$GOPATH/src/github.com/hlf-go/fabric/` and execute this command (on macOS and Linux only):

    ```
    ./fabricOps.sh start
    ```

    This will take sometime. The process will download docker images and setup your docker containers.

1. Execute the following command:

    ```
    ./fabricOps.sh cli
    ```

    In your bash terminal, you will be presented with the terminal running from the `cli` container:

    ```
    root@<your-container-id>:/opt/gopath/src/github.com/hyperledger/fabric/peer#
    ```
1. In the `cli` execute this command:

    ```
    root@<your-container-id>:/opt/gopath/src/github.com/hyperledger/fabric/peer# ./scripts/myfirstchaincode.sh
    ```

    This will execute a chaincode found in [`$GOPATH/src/github.com/hlf-go/writing-chaincodes/chaincodes/myfirstchaincode/chaincode.go`](../chaincodes/myfirstchaincode/chaincode.go). The chaincode is very simple. It will produce the following console output `Hello Init` when the chaincode method `Init` is called. `Hello Invoke` when the chaincode method `Invoke` is called.

    The script reponsible for executing the chaincode is found in [`$GOPATH/src/github.com/hlf-go/writing-chaincodes/fabric/scripts/myfirstchaincode.sh`](./scripts/myfirstchaincode.sh).Please study it.

1. Open another terminal, navigate to `$GOPATH/src/github.com/hlf-go/fabric` and execute this command:

    ```
    ./fabricOps.sh status
    ```

    This should display the following running containers:

    ```
    dev-peer0.org1.example.com-mycc-1.0: Up 38 seconds
    peer0.org1.example.com: Up About a minute
    orderer.example.com: Up About a minute
    cli: Up About a minute
    ```
    Note, message may be slightly different in terms of up time.

1. In the same terminal as the above step, execute the following command:

    ```
    docker logs dev-peer0.org1.example.com-mycc-1.0
    ```

    This should produce the following:

    ```
    Hello Init
    Hello Invoke
    ```

# <a name="movingOn">Moving on</a>

The training materials presented here are extremely stunted to help you understand very basic concepts. 

If you feel that you have the confidence to move on from this material feel free to fork it and make all the changes to suit your needs.  

# Disclaimer

The methodologies discussed in this document and artefacts in this repository are intended only to illustrate concepts and are for educational purpose.

There is no guarantee that these artefacts are free from defects. These are **NOT** intended for used in any mission critical, corporate or regulated projects. Should you choose to use them for these types of projects, you do so at your own risk.

Unless otherwise specified, the artefacts in this repository are distributed under Apache 2 license. In particular, the chaincodes are provided on "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

