# Copyright 2017 Billy Holmes
#
#   Licensed under the Apache License, Version 2.0 (the "License");
#   you may not use this file except in compliance with the License.
#   You may obtain a copy of the License at
#
#       http://www.apache.org/licenses/LICENSE-2.0
#
#   Unless required by applicable law or agreed to in writing, software
#   distributed under the License is distributed on an "AS IS" BASIS,
#   WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#   See the License for the specific language governing permissions and
#   limitations under the License.

REPO?=my-local-registry.example.com
U?=rhel7
NAME?=rhevm
VERSION?=4.0-0

TOUCH:=.docker-built

FULL_NAME:=$(if $(NAME),$(U)/$(NAME),$(U))
IMAGE_NAME:=$(REPO)/$(FULL_NAME):$(VERSION)

.PHONY:all compile clean

all: compile

compile: $(TOUCH)

$(TOUCH): Dockerfile Makefile
	docker build -t $(IMAGE_NAME) .
	touch $(TOUCH)

clean:
	rm -f $(TOUCH)
