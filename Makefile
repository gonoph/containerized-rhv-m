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
