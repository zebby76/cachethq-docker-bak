#!/usr/bin/python
import os
import sys
import logging
import getopt

import cachetclient.cachet as cachet
import json

from xml.sax.handler import ContentHandler
import xml.sax
import xml.parsers.expat
import xml.sax

# Todo: made a table with corresponding technical application name to business application name

class FoglightXMLHandler(xml.sax.handler.ContentHandler):

    def __init__(self):
        self._result = {}
        self._results = []

        self.inComponentName = 0
        self.inAvailability = 0
        self.inRuntime = 0

        self._name = ''
        self._availabilityAvg = ''
        self._runtimeAvg = ''
        self._runtimeSampleAvg = ''
        self._availabilitySampleAvg = ''

    def parse(self, f):
        xml.sax.parse(f, self)
        self._result['ApplicationInstances'] = self._results
        return self._result

    def characters(self, data):
        if self.inComponentName:
            self._name = data

    def startElement(self, name, attrs):
        if name == 'component_name':
            self.inComponentName = 1
        elif name == 'availability':
            self.inAvailability = 1
            self._availabilityAvg = attrs.getValue("avg")
        elif name == 'runtime':
            self.inRuntime = 1
            self._runtimeAvg = attrs.getValue("avg")
        elif name == 'sample':
            if self.inAvailability:
                self._availabilitySampleAvg = attrs.getValue("avg")
            elif self.inRuntime:
                self._runtimeSampleAvg = attrs.getValue("avg")
        elif name == 'SMALS_XML_ApplicationInstance':
            self._results.append({})

    def endElement(self, name):
        if name == 'component_name':
            self.inComponentName = 0
        elif name == 'availability':
            self.inAvailability = 0
        elif name == 'runtime':
            self.inRuntime = 0
        elif name == 'SMALS_XML_ApplicationInstance':
            self._results[-1]['runtime_last_sample_avg'] = self._runtimeSampleAvg
            self._results[-1]['runtime_avg'] = self._runtimeAvg
            self._results[-1]['availability_last_sample_avg'] = self._availabilitySampleAvg
            self._results[-1]['availability_avg'] = self._availabilityAvg
            self._results[-1]['name'] = self._name

def usage():
    print ("Usage : ")
    print ("")
    print ("  import-foglight-2-cachethq.py [-a --cachethq_auth_url] <auth_url> ")
    print ("                                [-t --cachethq_auth_token] <auth_token> ")
    print ("                                [-g --cachethq_group_name] <group_name>")
    print ("                     (Optional) [-f --name_filter] <filter>")
    print ("")
    print ("Note : Make sure to place the file 'smalsxmlmetrics.xml' retrieved from Foglight ")
    print ("       next to this script.")
    print ("       This script assume that the CachetHQ group already exists.")
    sys.exit(1)

def getCachetHQ():

    logger.info("Retrieve all Groups / Components already existing in CachetHQ ...")

    existing_groups = cachet.Groups(endpoint=CACHETHQ_ENDPOINT, api_token=CACHETHQ_API_TOKEN, pagination=False)
    existing_groups_json = json.loads(existing_groups.get(name=str(CACHETHQ_GROUP_NAME)))

    cachethq = {}
    groups = []

    for existing_group in existing_groups_json['data']:
        group = {}
        group['id'] = existing_group['id']
        group['name'] = existing_group['name']
        group['created_at'] = existing_group['created_at']
        group['updated_at'] = existing_group['updated_at']

        components = []

        for enabled_components in existing_group['enabled_components']:
            component = {}
            component['id'] = enabled_components['id']
            component['name'] = enabled_components['name']
            component['created_at'] = enabled_components['created_at']
            component['updated_at'] = enabled_components['updated_at']

            components.append(component)

        group['components'] = components

        groups.append(group)

    cachethq['groups'] = groups

    return (cachethq)

def getFoglight():

    logger.info("Retrieve metrics from Foglight XML exported file ...")

    # Todo: retrieve XML file from Foglight URL

    components = FoglightXMLHandler().parse("files/inputfile.xml")

    return (components)

def checkComponents(foglight, cachethq):

    logger.info("Check CachetHQ components and update if no metrics retrieved from Foglight ...")

    for group in cachethq['groups']:

        filtered_components = (component for component in group['components'] if NAME_FILTER in component['name'])

        for component in filtered_components:

            applicationFound = False

            for application in foglight['ApplicationInstances']:

                if (component['name'].lower() == application['name'].lower()):
                    applicationFound = True
                    status = 4

            if not applicationFound:
                updateComponent(component['id'],status)
                # Todo: create CachetHQ incident

def checkApplications(foglight, cachethq):

    logger.info("Check Foglight monitoring and update CachetHQ components ...")

    filtered_applications = (application for application in foglight['ApplicationInstances'] if NAME_FILTER in application['name'])

    for application in filtered_applications:

        if int(float(application['availability_last_sample_avg'])) == 100:
            status = 1
        else:
            status = 4

        for group in cachethq['groups']:

            componentFound = False
            componentId = 0
            groupId  = group['id']

            for component in group['components']:

                if (component['name'].lower() == application['name'].lower()):
                    componentFound = True
                    componentId = component['id']

            if componentFound:
                updateComponent(componentId,status)
            else:
                createComponent(application['name'],status,groupId)

def updateComponent(id, status):

    logger.info("Update CachetHQ component %s with status %s ..." % (id,status) )

    components = cachet.Components(endpoint=CACHETHQ_ENDPOINT, api_token=CACHETHQ_API_TOKEN)

    # Bad and Ugly workaround to force updated_at field : https://github.com/CachetHQ/Cachet/issues/2802
    components.put(id=str(id),status=str(0))
    components.put(id=str(id),status=str(status))

def createComponent(name, status, groupId):

    logger.info("Create CachetHQ component %s with status %s in group %s ..." % (name,status, groupId) )

    components = cachet.Components(endpoint=CACHETHQ_ENDPOINT, api_token=CACHETHQ_API_TOKEN)

    new_component = json.loads(components.post(name=str(name),
                                               status=status,
                                               description=str('Automatic component creation'),
                                               group_id=str(groupId)
                                               ))

    component_id = new_component['data']['id']
    components.put(id=component_id,status=status)

def main(argv):

    global logger

    global CACHETHQ_ENDPOINT
    global CACHETHQ_API_TOKEN
    global CACHETHQ_GROUP_NAME
    global NAME_FILTER

    CACHETHQ_ENDPOINT = ""
    CACHETHQ_API_TOKEN = ""
    CACHETHQ_GROUP_NAME = ""
    NAME_FILTER = ""

    try:
        opts, args = getopt.getopt(argv, "a:t:g:f:", ["cachethq_auth_url=", "cachethq_auth_token=", "cachethq_group_name=", "name_filter="])
    except getopt.GetoptError as err:
        print (err)  # will print something like "option -a not recognized"
        usage()
        sys.exit(2)

    for o, a in opts:
        if o in ("-a", "--cachethq_auth_url"):
            CACHETHQ_ENDPOINT = a
        elif o in ("-t", "--cachethq_auth_token"):
            CACHETHQ_API_TOKEN = a
        elif o in ("-g", "--cachethq_auth_token"):
            CACHETHQ_GROUP_NAME = a
        elif o in ("-f", "--name_filter"):
            NAME_FILTER = a
        else:
            usage()
            return 2

    if not len(CACHETHQ_ENDPOINT) > 0 or \
       not len(CACHETHQ_API_TOKEN) > 0 or \
       not len(CACHETHQ_GROUP_NAME) > 0:
       print("Mandatory options cannot be null or undefined !")
       usage()
       return 2

    logging.basicConfig(level=logging.INFO)
    logger = logging.getLogger(__name__)

    foglight = getFoglight()
    cachethq = getCachetHQ()

    checkApplications(foglight, cachethq)
    checkComponents(foglight, cachethq)

if __name__ == '__main__':
  sys.exit(main(sys.argv[1:]))
