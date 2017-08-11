# Introduction

The purpose of this article is to provide you with 1) minimal knowledge of Go, and 2) a view of developing chaincode from coding (not abstract) perspective. Armed with these basic knowledger you will be able to extend the knowledge to do advance chaincode development.

This article is intended for anyone with programming experience but having no or very little experience of Go and chaincode development. You will be expected to know concepts compilation and packaging as Go is a compiled, not scripting, langauge.

If you are already an experience Go developer please refer to [hyperledger fabric documentation for advance instruction](http://hyperledger-fabric.readthedocs.io/en/latest/chaincode4ade.html).

In this article, you will learn to:

* [Setup for chaincode development](#setupDevEnv)
* [Minimal Go for chaincode development](#learnGo)
* [Write chaincodes](#goForChaincode)
* [Install, instatiate and invoke chaincode](#runChaincode)
* [Example chaincode](#exampleChaincode)

# <a name="setupDevEnv">Setup for chaincode development</a>

Setting up a development environment for chaincode projects is no different from setting up for other non chaincode Go projects. 

For a basic (terminal and command-line) environment for chaincode development, please follow the following steps:

1. Install [Go tools](http://golang.org/dl).
    * for macOS, we recommend installing via [homebrew](http://brew.sh/);
    * for other platforms please refer to [installation guide](https://golang.org/doc/install).

1. Set the environmental variable `GOPATH` to a reference a directory to host your Go source codes and binaries (i.e. Go workspace). For example,
    
    ```
    export GOPATH=$HOME/go-projects
    ```

1. Install a GO application call [Govendor](https://github.com/kardianos/govendor) by executing this command:
    
    ```
    go get -u github.com/kardianos/govendor
    ```

    At the completion of the command, you will find in `GOPATH` three directories:

    ```
    drwxr-xr-x  3 <userid>  <groupid>  102  3 Feb 15:44 bin
    drwxr-xr-x  3 <userid>  <groupid>  102  3 Feb 15:44 pkg
    drwxr-xr-x  3 <userid>  <groupid>  102  3 Feb 15:44 src
    ```

    This structure is dictated by Go tooling and will be your primary workspace for organising your chaincodes and and other dependencies such as third parties codes, tooling extensions, etc.

    In the context of chaincode development, you will be working directly Go sources. Hence, you only need to concern yourself with organising stuff within `src` directory.

    **Note:**

    * This step is not strictly needed. You could have create the workspace directories manually.

    * [Govendor](https://github.com/kardianos/govendor) is a package or dependency management tool. It is one of many tools you can use to manage Go dependencies. The choice of `Govendor` is purely based on familarity. You could elect to install [other tools](https://github.com/golang/go/wiki/PackageManagementTools)).

1. Add the `$GOPATH/bin` to your `PATH` environmental variable. For example:

    ```
    export PATH=$GOPATH/bin:$PATH
    ```

    `$GOPATH/bin` is a directory for binaries generated from Go source compilation. Some of these binaries may be used to extend the functionalities of Go tooling or any other support tools. If you are using [Visual Studio Code](https://code.visualstudio.com/), you will find extensions to the editor such as code completion or syntax highlighting, served from this directory.

# <a name="learnGoLang">Minimal Go for Chaincode</a>

To learn more about Go progranmning language, please refer to these resources:

* [Go playground](https://play.golang.org/) - This a a web-base development environment where you can learn to code in Go without the need to setup a local development environment.

* [Go by example](https://gobyexample.com/) - This is a series of code snippets demonstrating features of Go by theme.

To create a minimal chaincode focus your learning on these areas 

* [data types](https://gobyexample.com/variables);
* [functions](https://gobyexample.com/functions);
* [structs](https://gobyexample.com/structs);
* [interfaces](https://gobyexample.com/interfaces).

You will also need to be aware that all your Go (chaincode) codes needs to organised around `$GOPATH/src` directory. For example, here is a hypothetical structure:

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

Organise your code and dependencies to reflect that way codes would be stored in a typical Git-like code repositories. Please refer to the official documentation on [code organisation](https://golang.org/doc/code.html#Organization).

# <a name="goForChaincode">Writing chaincode</a> 

In this section you will learn to:

* [write the smallest unit of executable chaincode](#smallestchaincode);
* [organise your chaincode project](#organiseChaincode).

### <a name="smallestchaincode">Smallest unit of executable chaincode</a>

The minimal executable Go code is this:

```
package main

import "fmt"

func main() {
	fmt.Printf("Hello, world.\n")
}

```

To compile and execute this code all you need to do is to issue the command `go run`. It will run in your macOS, Linux, Windows or any compatible platform.

In the case of chaincode the smallest unit of executable code is this:

```
package main

import (
    "fmt"

    "github.com/hyperledger/fabric/core/chaincode/shim"
    pb "github.com/hyperledger/fabric/protos/peer" 
)

type SimpleChaincode struct{}

func (t *SimpleChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
    return pb.Response{Status: 0, Message: "nothing", Payload: []byte{0, 0}}
}

func (t *SimpleChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
    return pb.Response{Status: 0, Message: "nothing", Payload: []byte{0, 0}}
}

func main() {
    err := shim.Start(new(SimpleChaincode))
    if err != nil {
        fmt.Printf("Error: %s", err)
    }
}
```

Place your code in the file `chaincode.go` under the appropriate part of you Go workspace for example, `$GOPATH/src/github.com/user/repo/chaincode.go`.

To get a sense of whether the code is workable, go to the location of your main chaincode file and execute `go run` command. example

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

This is a runtime error message and it simply indicates that the chaincode has been executed. However, it has no hyperledger fabric infastructure to interact with so this error message occur.

Unlike normal Go program, you can't just compile and run the code. Instead you will need to bundle the code and deploy it to the hyperledger fabric platform known as fabric peer (see [architecture](http://hyperledger-fabric.readthedocs.io/en/latest/arch-deep-dive.html#system-architecture) for detailed explanation). The fabric peer will compile and run the code.

**Note:**

* In the import clause, you see this `github.com/hyperledger/fabric/core/chaincode/shim`, which is a hyperledger fabric component
* You will find the component in `$GOPATH/src/github.com/hyperledger/fabric`.
* When you execute `go run` Go will pull this dependency from Github repo. Alternatively you could issue this command `go get -d github.com/hyperledger/fabric` to pull the dependency from Github repo.

### <a name="organiseChaincode">Organising your chaincode project</a>

It is extremely unusual to create a chaincode from a single file. You may want to re-use aspects of a Go code developed by third parties and/or separate out your functional from non-functional (e.g. string formatter) dependencies. Hence, you would want to organise in different files and/or directories.

If you were writing Go project you would organise your dependencies this way:

```
$GOPATH/
    src/
        github.com/user/repo/
            mypkg/
                mysrc1.go
                mysrc2.go
            cmd/mycmd/
                main.go
```

This is minimally sufficient to compile and run code on macOS, Linux, Windows, etc.

In the case of chaincode development, this structure will not work. You will need to organise all your dependencies under one root directory and then deploy the root directory to fabric peer. 

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
                        github.com/user/repo
                            mysrc1.go
                            mysrc2.go
                        vendor.json
```
In this example:

* `mychaincode` directory is the root directory encapsulating all you chaincode and dependencies. 
* `util` is a customer directory created by the developer. 
* `vendor` is a special directory (with a file `vendor.json`) typically to package dependencies not located at the chaincode root or third parties. Please refer to https://blog.gopheracademy.com/advent-2015/vendor-folder/ for detailed explanations.

You can manually create and provision the `vendor` directory but using tools makes it easier. As per the [setup step](#setupDevEnv), let's use `Govendor` to `vendor` your dependencies: 

1. Navigate to `$GOPATH/src/github.com/user/repo/mychaincode` and execute this command:

    ```
    govendor init
    ```

   You should see a sub folder call `vendor` created.

1. In the folder `vendor` add the following line to `vendor.json`:

    ```
    "ignore": "test github.com/hyperledger/fabric"
    ```

    This line tells `govendor` not to include `github.com/hyperledger/fabric` and test dependencies. You don't need to include hyperledger fabric dependency because it is part of the fabric peer infrastructure.

1. We are going to `vendor` dependencies found in `github.com/user/repo`. Issue this command:

    ```
    govendor fetch github.com/user/repo
    ```

    If no error you will see the dependencies stored in `vendor` directory.

# <a name="runChaincode">Install, instatiate and invoke chaincode</a>

TO DO

# <a name="exampleChaincode">Example chaincode</a>

TO DO

# Disclaimer

The artefacts in this repository are intended only to illustrate concepts and are for educational purpose.

There is no guarantee that these artefacts are free from defects. These are NOT to be used or re-produced in any mission critical, corporate or regulated infrastructure. Should you choose to use or re-produce them for your project yo do so at your own risk.

Unless otherwise specified, the artefacts in this repository are distributed under Apache 2 license. In particular, the chaincodes are provided on "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.

