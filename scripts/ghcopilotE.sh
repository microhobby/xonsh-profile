#!/bin/bash

keyword=Explanation:

echo "" | gh copilot explain "$@" 2>/dev/null | grep --color=always $keyword -A999 | grep --color=always -v $keyword
