import json
import launchpadlib
import re
import sys

from launchpadlib.launchpad import Launchpad
from lazr.restfulclient.errors import HTTPError

record_re = re.compile(r"\.(?P<date>[0-9]+)\.(?P<commit>[0-9a-f]+)~ubuntu(?P<os>[0-9]+\.[0-9]+)\.[0-9]$")

def tokenize_record(record):
    build = {}
    match = record_re.search(record.source_package_version)
    if None != match:
        build["version"] = record.source_package_version
        build["arch"] = record.arch_tag
        build["date"] = match.group("date")
        build["commit"] = match.group("commit")
        build["os"] = match.group("os")
    return build

ppa_name = sys.argv[1]
records = int(sys.argv[2])
release = sys.argv[3]
arch = sys.argv[4]

try:
    launchpad = Launchpad.login_anonymously("mythbuntu-ppa-query", "production", version="devel")
    mythbuntu = launchpad.people["mythbuntu"]
    ppa = mythbuntu.getPPAByName(name=ppa_name)
    all_records = ppa.getBuildRecords(build_state = "Successfully built")[:records]
    arch_records = (record for record in all_records if record.arch_tag == arch)
    arch_builds = (tokenize_record(record) for record in arch_records)
    os_builds = [build for build in arch_builds if release == build["os"]]
    index_builds = [os_builds[index].update({ "index": index}) or os_builds[index] for index in range(len(os_builds))]
    json = json.dumps(index_builds)
    print(f"::set-output name=build-records::{json}")

except HTTPError as e:
    print(f"::set-output name=package-versions::[]")
    print(f"::set-output name=latest-version::\"\"")
    print(f"::error file=action.yml,line=37::{e.content}")
    sys.exit(1)
