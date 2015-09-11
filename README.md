# Containerised scientific Python workstation

This container (based on
[ipython/scipystack](https://hub.docker.com/r/ipython/scipystack/)) provides a
containerised research environment suitable for scientific use with a particular
emphasis on Computer Vision.

In addition to the packages pulled in via scipystack, this container also pulls
in a recent version of the Jupyter notebook server and installs OpenCV 3 for
both Python 3 and Python 2. The ``opencv_contrib`` modules are also installed.

The container exposes a single port which the Jupyter notebook server runs on.
Launch the container with an incantation similar to the following:

```console
$ docker run -i -p 8888:8888/tcp rjw57/jupyter
```

By default the Jupyter notebook runs as a user which is given ``sudo`` access
inside the container. **NOTE THAT HAVING ROOT IN THE CONTAINER SHOULD BE VIEWED
AS HAVING ROOT ON THE HOST.** The user logon name and id can be configured by
setting the ``USER`` and ``USER_UID`` environment variables. For example, to
launch the container for the current user:

```console
$ docker run -i -p 8888:8888/tcp -e USER -e USER_UID=$(id -u) rjw57/jupyter
```

Some niceties of configuration include:

* A fresh version of OpenCV.
* Versions of ``pip`` for Python 2 and Python 3 are available via ``pip2`` and
    ``pip3``.
* ``pip`` is configured so that ``pip install`` will install the package into
    the user's home directory.
* The user's profile is configured to put ``~/.local/bin`` on the path so
    packages installed via ``pip`` which have command-line scripts will work as
    expected.

