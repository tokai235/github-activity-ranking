# docker image ビルド
PHONY: docker-build
docker-build:
	docker build -f build/package/Dockerfile -t ranking-app .

# docker 起動
PHONY: docker-run
docker-run:
	docker run -it ranking-app
