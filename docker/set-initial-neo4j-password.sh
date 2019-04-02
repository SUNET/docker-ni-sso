#!/bin/sh
PASSWORD=${1:-"docker"}
curl -H "Content-Type: application/json" -X POST -d "{\"password\":\"$PASSWORD\"}" -u neo4j:neo4j http://neo4j:7474/user/neo4j/password
