from TeproAlgo import TeproAlgo
from TeproDTO import TeproDTO


class TeproApi(object):
    """This is the Python class that each NLP app
    has to implement so that it can be plugged into
    the TEPROLIN platform."""

    def __init__(self):
        """The constructor gets the name of the NLP application/algorithm
        that is used by 'TeproAlgo' to construct allowed operation
        chains."""

        self._algoName = ""

    def getAlgoName(self):
        return self._algoName

    def loadResources(self):
        """Call this method after createApp so that
        the NLP app can load all resources it needs."""

        pass

    def createApp(self):
        """Call this method so that the process is spawned
        and the app is waiting for input."""

        pass

    def destroyApp(self):
        """This method will 'gracefully' destroy the NLP app."""

        pass

    def _checkProgress(self, dto: TeproDTO) -> list:
        """Checks what operations have been perforemed already
        and what needs to be done futher."""
        opNotDone = []

        for op in TeproAlgo.getOperationsForAlgo(self._algoName):
            if not dto.isOpPerformed(op) or \
                    self._algoName == dto.getConfiguredAlgoForOper(op):
                opNotDone.append(op)

        return opNotDone

    def _runApp(self, dto: TeproDTO, opNotDone: list) -> TeproDTO:
        """This is the method that does the actual work
        of this NLP app. Takes the list of currently not done
        operations."""

        return dto

    def doWork(self, dto: TeproDTO) -> TeproDTO:
        """The main method that has to be called so that the app
        can perform its work on 'dto' of type TeproDTO. The result
        is written in 'dto' which is an object reference."""

        notdone = self._checkProgress(dto)

        # Return if everything is done.
        if not notdone:
            return

        dto = self._runApp(dto, notdone)

        for op in notdone:
            dto.addPerformedOp(op)

        return dto
