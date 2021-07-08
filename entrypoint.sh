#!/bin/sh -v

echo "Executing command..."
sh -c "$*"
exit_code=$?

echo "Done."
exit $exit_code
