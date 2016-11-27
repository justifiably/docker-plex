MYPLEXTOKEN=$(shell cat myplextoken.secret)

# I pass in BUILDARGS for local http cache
NEWBUILDARGS=$(BUILDARGS) --build-arg MYPLEXTOKEN=$(MYPLEXTOKEN)

build:
	docker build $(NEWBUILDARGS) -t justifiably/plex .
