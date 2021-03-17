import platform
import os
from multiprocessing import freeze_support
from http import HTTPStatus
from flask import Flask, request, send_from_directory
from flask_restful import Api, Resource
from Teprolin import Teprolin
from TeproAlgo import TeproAlgo

# Author: Radu ION, (C) ICIA 2018-2020
# Part of the TEPROLIN platform.
# Uses Flask-based Flask-RESTful api for creating the
# REST web service for the TEPROLIN platform.
class TeproREST(Resource):
    """This is the REST web-service version of the Teprolin class.
    Just run this module and it will start the WS for you."""

    def __init__(self, *args):
        super().__init__()
        self._teprolin = args[0]

    def post(self):
        """Returns the client key used for a
        config/processing request.
        Expected key=value pairs:
        <Teprolin operation>=<Teprolin NLP app> (0 or more)
        exec=<Teprolin operation>,<Teprolin operation>,... (0 or more)
        text=<text to be processed> (exactly 1)"""
        text = None

        # 1. Get the text for processing
        if 'text' in request.form:
            text = request.form['text']
        else:
            return ({
                'teprolin-conf': self._teprolin.getConfiguration(),
                'teprolin-result': 'No text="..." field has been supplied!'},
                int(HTTPStatus.BAD_REQUEST))

        # 2. Do the requested configurations,
        # if such pairs exist
        noConfigRequested = True

        for op in TeproAlgo.getAvailableOperations():
            if op in request.form:
                algo = request.form[op]

                try:
                    self._teprolin.configure(op, algo)
                    noConfigRequested = False
                except RuntimeError as err:
                    return ({
                        'teprolin-conf': self._teprolin.getConfiguration(),
                        'teprolin-result': str(err)},
                        int(HTTPStatus.BAD_REQUEST))

        # 2.1 If no configuration was requested,
        # go to the default configuration for the object.
        # Clear previous configuration requests.
        if noConfigRequested:
            self._teprolin.defaultConfiguration()

        # 3. Extract the requested text processing
        # operations. If none is specified, do the full
        # processing chain.
        requestedOps = []

        if 'exec' in request.form:
            exop = request.form['exec'].split(",")

            for op in exop:
                if op in TeproAlgo.getAvailableOperations():
                    requestedOps.append(op)
                else:
                    return ({
                        'teprolin-conf': self._teprolin.getConfiguration(),
                        'teprolin-result': "Operation '" + op + "' is not recognized. See class TeproAlgo."},
                        int(HTTPStatus.BAD_REQUEST))

        # 4. Do the actual work and return the JSON object.
        if requestedOps:
            dto = self._teprolin.pcExec(text, requestedOps)
        else:
            dto = self._teprolin.pcFull(text)

        return ({
            'teprolin-conf': self._teprolin.getConfiguration(),
            'teprolin-result': dto.jsonDict()},
            int(HTTPStatus.OK))


class TeproStats(Resource):
    def __init__(self, *args):
        super().__init__()
        self._teprolin = args[0]

    def get(self, svalue, tvalue, hsize):
        """This method will return the available Teprolin
        stats per type of statistic 'svalue' and type of
        time interval 'tvalue'."""
        if svalue != Teprolin.statsTokens and \
                svalue != Teprolin.statsRequests:
            return ({
                'teprolin-conf': self._teprolin.getConfiguration(),
                'teprolin-result': "Statistics type '" + svalue + "' is not recognized. See class Teprolin."},
                int(HTTPStatus.BAD_REQUEST))

        if tvalue != Teprolin.statsYear and \
                tvalue != Teprolin.statsMonth and \
                tvalue != Teprolin.statsDay:
            return ({
                'teprolin-conf': self._teprolin.getConfiguration(),
                'teprolin-result': "Time interval type '" + tvalue + "' is not recognized. See class Teprolin."},
                int(HTTPStatus.BAD_REQUEST))

        if not isinstance(hsize, int):
            return ({
                'teprolin-conf': self._teprolin.getConfiguration(),
                'teprolin-result': "History size is not an int."},
                int(HTTPStatus.BAD_REQUEST))

        return ({svalue: self._teprolin.getStats(svalue, tvalue, hsize)}, int(HTTPStatus.OK))


class TeproNLPApps(Resource):
    def __init__(self, *args):
        super().__init__()
        self._teprolin = args[0]

    def get(self, oper):
        """This method will return the available Teprolin
        algorithms (NLP apps) for the specified 'oper'."""

        if oper in TeproAlgo.getAvailableOperations():
            return ({oper: TeproAlgo.getAlgorithmsForOper(oper)}, int(HTTPStatus.OK))
        else:
            return ({
                'teprolin-conf': self._teprolin.getConfiguration(),
                'teprolin-result': "Operation '" + oper + "' is not recognized. See class TeproAlgo."},
                int(HTTPStatus.BAD_REQUEST))


class TeproOperations(Resource):
    def __init__(self, *args):
        super().__init__()

    def get(self):
        """This method will return the available Teprolin
        algorithms (NLP apps) for the specified 'oper'."""

        return ({"can-do": TeproAlgo.getAvailableOperations()}, int(HTTPStatus.OK))


class TeproHelpIndex(Resource):
    def __init__(self, *args):
        super().__init__()

    def get(self):
        """This method will return the index.html
        help for the WS."""

        return send_from_directory("", "index.html")


class TeproHelpPNG(Resource):
    def __init__(self, *args):
        super().__init__()

    def get(self, img):
        """This method will return the referenced
        images in index.html."""

        return send_from_directory("images", img)


class TeproFavicon(Resource):
    def __init__(self, *args):
        super().__init__()

    def get(self):
        """This method will return the favicon.ico
        file ;)"""

        return send_from_directory("", "favicon.ico")


class TeproTerminate(Resource):
    def __init__(self, *args):
        super().__init__()

    def get(self):
        """This method will gracefully shutdown
        the Flask server."""

        func = request.environ.get('werkzeug.server.shutdown')

        if func is not None:
            func()
        else:
            return ({
                'teprolin-conf': self._teprolin.getConfiguration(),
                'teprolin-result': "Cannot shutdown server..."},
                int(HTTPStatus.FORBIDDEN))


# Call freeze_support() first in Windows...
if platform.system() == 'Windows':
    freeze_support()

# The Teprolin object.
# This one is configured and used
# for processing operations.
tepro = Teprolin()
app = Flask(__name__)
# Configure flask_restful to jsonify
# arbitrary objects.
app.config['RESTFUL_JSON'] = {
    'default': lambda x: x.__dict__,
    'ensure_ascii': False,
    'sort_keys': True,
    'indent': 2
}
api = Api(app)

# GET the available algorithms for
# the given operation
api.add_resource(TeproNLPApps, '/apps/<string:oper>', resource_class_args=[tepro])
# GET the available operations for the
# platform
api.add_resource(TeproOperations, '/operations')

# GET the available statistics tables per
# time interval: year, month or day and per
# type of statistics: token, char or request
api.add_resource(
    TeproStats, '/stats/<string:svalue>/<string:tvalue>/<int:hsize>', resource_class_args=[tepro])

# POSTs the data for configuration and processing
api.add_resource(TeproREST, '/process', resource_class_args=[tepro])

# The index.html help page
api.add_resource(TeproHelpIndex, '/')
api.add_resource(TeproHelpPNG, '/images/<string:img>')
api.add_resource(TeproFavicon, '/favicon.ico')

if os.environ.get('TEPROLIN_DOCKER') is None and platform.system() != 'Linux':
    # If you run this with uwsgi, comment out the next 2 lines!
    api.add_resource(TeproTerminate, '/server-shutdown-now')
    app.run(host='0.0.0.0', port=5000)
