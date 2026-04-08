.PHONY: docker-build docker-build-postgres-nio

DOCKER_IMAGE ?= cranectl

define append-description
sed 's/org.opencontainers.image.description="\(.*\)"/org.opencontainers.image.description="\1 $(1)"/'
endef

Dockerfile.default: DESCRIPTION = All-in-one build with support for all first-party migration targets.
Dockerfile.default: Dockerfile.template
	$(call append-description,$(DESCRIPTION)) Dockerfile.template > Dockerfile.default

Dockerfile.postgres-nio: DESCRIPTION = Only contains support for the postgres-nio migration target.
Dockerfile.postgres-nio: Dockerfile.template
	sed 's/swift build -c release/swift build -c release --traits PostgresNIO/' Dockerfile.template \
		| $(call append-description,$(DESCRIPTION)) > Dockerfile.postgres-nio

docker-build: Dockerfile.default
	docker build -f Dockerfile.default -t $(DOCKER_IMAGE):latest .

docker-build-postgres-nio: Dockerfile.postgres-nio
	docker build -f Dockerfile.postgres-nio -t $(DOCKER_IMAGE):latest-postgres-nio .
