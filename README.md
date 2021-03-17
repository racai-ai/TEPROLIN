# Teprolin
**Teprolin** is a `Python` platform for text pre-processing that has been developed in the [Teprolin project](http://www.racai.ro/p/reterom/).
It is described in the following paper ([click to read it from the conference proceedings](https://profs.info.uaic.ro/~consilr/wp-content/uploads/2019/06/volum-ConsILR-2018-1.pdf)):

**Ion**, **Radu**. (2018). _**TEPROLIN**: An Extensible, Online Text Preprocessing Platform for Romanian_. In Proceedings of the International Conference on Linguistic Resources and Tools for Processing Romanian Language (ConsILR 2018), November 22-23, 2018, Iași, România.

## Installation
**Teprolin** only works with `Python 3` and it has been tested with versions `3.6`, `3.7` and `3.8` on both `Windows 10` and `Linux Ubuntu 20.04`. **Teprolin** includes the [**TTL** text pre-processor](http://www.racai.ro/media/WSD.pdf) which runs in `Perl`. In Windows, we used [Strawberry Perl](http://strawberryperl.com/) and in Ubuntu, the default `perl` installation.

### TTL
To make sure **TTL** works, issue the following commands in a `perl`-enabled command prompt (`perl` has to be in `PATH`):

`cpan install Unicode::String`

`cpan install Algorithm::Diff`

`cpan install BerkeleyDB`

`cpan install File::Which`

`cpan install File::HomeDir`

Check that the script named `TeproTTL.pl` compiles OK by executing `perl -c TeproTTL.pl`.

### NLP-Cube and UD-Pipe
[NLP-Cube](https://github.com/adobe/NLP-Cube) and [UD-Pipe 1](http://ufal.mff.cuni.cz/udpipe/1) have their own repositories at GitHub.

### TTS Frontend
SSLA is a Text-To-Speech library developed by Tiberiu Boroș et al.
Read about it on [arXiv](https://arxiv.org/pdf/1802.05583.pdf). The source code can be found on GitHub at [SSLA](https://github.com/racai-ai/ssla).
MLPLA is the text preprocessing front-end for SSLA and it is used in TEPROLIN for:
- word hyphenation
- word stress identification
- phonetic transcription

Additionally, we ported some code from our [ROBIN Dialog Manager project](https://github.com/racai-ai/ROBINDialog) to do numeral rewriting, also for the benefit of TTS tools.
In order to run MLPLA, you need Java Runtime Engine 15 installed and available in `PATH`.

If you want to build the MLPLAServer yourself, install the MLPLA text preprocessing library in your local Maven repository by running this command:

`mvn install::install-file -Dfile=ttsops/MLPLAServer/lib/MLPLA.jar -DgroupId=ro.racai -DartifactId=mlpla -Dversion=1.0.0 -Dpackaging=jar -DgeneratePom=true`

and, you need to run the following `mvn` command in order to generate the jar with all dependencies:

`mvn clean compile test assembly:single antrun:run@copy-uber-jar`

### Teprolin resource files
The resource files are models, lexicons, mapping files, etc. that are loaded by all NLP apps of Teprolin.
They sit in the `.teprolin` folder, under your home folder.
In `Windows 10` this is `%USERPROFILE%` and in `Linux`, `~`. These files are now automatically installed by TEPROLIN.

### Python 3 dependencies
To install all the related Python 3 packages in two commands, using a virtual environment, do this:

`python3 -m venv /path/to/new/virtual/environment`

then activate the new environment executing the `source /path/to/new/virtual/environment/bin/activate`. Finally, run

`pip3 install -r requirements.txt`

## Testing
For a quick test session, using small texts (say up to 1000 chars), head to [RELATE's](https://relate.racai.ro) [test page](https://relate.racai.ro/index.php?path=teprolin/complete). If you want to test different algorithms (e.g. UD-Pipe vs. NLP-Cube), you can access [this link](https://relate.racai.ro/index.php?path=teprolin/custom).

If you want to test the installation, issue `pytest -v tests` from the root of this repository. Please be patient, it will take a bit:

![](images/teprolin-testing.png)

### Running the REST web service
To quickly test the REST service, logging to console, run the following command from the root of this repository:

`python3 TeproREST.py`

to start the server in the foreground, with a single-process, in development mode.

**Only on Linux**: to start/stop the server in production mode using `uwsgi` for the RELATE platform, do this:

`pip3 install uwsgi`

`start-ws.sh`

`stop-ws.sh`

To start the server on three different ports for faster, multi-threaded processing, do this:

`start-ws-mt.sh`

`stop-ws-mt.sh`

## Docker container
The easiest way to use the Teprolin text processing platform is to get the already-built Docker container:

`docker pull raduion/teprolin:1.1`

from [Docker Hub](https://hub.docker.com/).

If you want to build the image yourself, just issue:

`docker build --pull --rm -f "Dockerfile" -t teprolin:1.1 "."`

or use the [Visual Studio Code Docker extension](https://github.com/microsoft/vscode-docker) along with [Docker Desktop](https://hub.docker.com/editions/community/docker-ce-desktop-windows).
