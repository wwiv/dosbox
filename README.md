# DOSBox with patches for BBSing


# Building on Windows

You can use Visual Studio 2015 and open the Solution named:
```./visualc_net/dosbox.sln```


# Building on Linux

You need a couple of packages to be installed:
* automake
* libsdl1.2-dev
* libsdl-net1.2-dev

Now change into the dosbox directory and compile the source.
Here's the commands I used.

```
cd dosbox
./autogen.sh
./configure
make -j12
```

Now dosbox will be created in your ```src/``` directory.

