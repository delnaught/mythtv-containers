import json
import launchpadlib
import re
import sys

from launchpadlib.launchpad import Launchpad
from lazr.restfulclient.errors import HTTPError

record_re = re.compile(r"^[^:]+:(?P<major>[0-9]+)\.(?P<minor>[0-9]+)[^\.]+\.(?P<date>[0-9]+)\.(?P<commit>[0-9a-f]+)~ubuntu(?P<os>[0-9]+\.[0-9]+)\.[0-9]$")

def tokenize_record(record, image):
    build = {}
    match = record_re.search(record.source_package_version)
    if None != match:
        build["image"] = image
        build["source"] = record.source_package_version
        build["arch"] = record.arch_tag
        build["major"] =  match.group("major")
        build["minor"] =  match.group("minor")
        build["date"] = match.group("date")
        build["commit"] = match.group("commit")
        build["os"] = match.group("os")
    return build

image_names = json.loads(sys.argv[1])
ppa_names = json.loads(sys.argv[2])
records = int(sys.argv[3])
release = sys.argv[4]
arch = sys.argv[5]

try:
    launchpad = Launchpad.login_anonymously("mythbuntu-ppa-query", "production", version="devel")
    mythbuntu = launchpad.people["mythbuntu"]
    all_builds = []
    for image_name in image_names:
        for ppa_name in ppa_names:
            ppa = mythbuntu.getPPAByName(name=ppa_name)
            all_records = ppa.getBuildRecords(build_state = "Successfully built")[:records]
            arch_records = (record for record in all_records if record.arch_tag == arch)
            arch_builds = (tokenize_record(record, image_name) for record in arch_records)
            os_builds = [build for build in arch_builds if release == build["os"]]
            all_builds += [os_builds[index].update({ "index": index}) or os_builds[index] for index in range(len(os_builds))]
    json = json.dumps(all_builds)
    print(f"::set-output name=build-matrix::{json}")

except HTTPError as e:
    print("::set-output name=build-matrix::{}")
    print(f"::error file=action.yml,line=43::{e.content}")
    sys.exit(1)
