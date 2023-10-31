# Instructions

## Installation
1. Clone the repository and `cd` into it.
   ```bash
   git clone https://github.com/alexanderkeijser73/pants-example-python
   cd pants-example-python
   git checkout from-scratch
   ```
2. Install the pants binary. You have two options:

   Install pants in a docker container (recommended):

   ```
    docker build -t pants-docker-installation .
    docker run --name=pants-example-python -v $(pwd):/app -itd pants-docker-installation &&\
    alias pants='docker exec pants-example-python pants'
    ```
   Install with brew: 
       
    ```
    brew install pants
    ```

## Inspect the repository
- There is a pyhon package, `helloworld`, that contains the following:
    - a script, main.py that runs a simple program
    - a subpackage `translator`, that translates greetings into different languages.
    - a subpackage `greet`, that implements functionality to display a greeting.
    - tests for both packages.

## Pants targets
1. Show which targets exist in the project:
    ```
    pants list ::
    ```
2. Generate BUILD files:
    ```
    pants tailor ::
    ```

## Show dependencies
1. Show direct dependencies of main.py:
    ```
    pants dependencies helloworld/main.py
    ```
2. Show transitive dependencies of main.py:
    ```
    pants dependencies --transitive helloworld/main.py 
    ```
3. Show which targets direcltly depend on main.py:
    ```
    pants dependents helloworld/main.py 
    ```
4. Get information about a target:
    ```
    pants peek helloworld:helloworld
    ```


## Executing targets
1. Run main.py:
    ```
    pants run helloworld/main.py
    ```
    Results in error because we don't have a target for translations.json!
2. Fix it by adding a resource target for translations.json:
    - go to greet/BUILD
    - add a resource target for translations.json
    ```
    python_sources(dependencies=[":translations-json"])

    resource(
      name="translations-json",
      source="translations.json",
    )
    ```
3. Try running main again:
    ```
    pants run helloworld/main.py
    ```

  Success :)


## Running tests
1. Run all tests:
    ```
    pants test ::
    ``` 
2. Run only tests affected by changes:
    - check out the main branch
    - make a change to one of the files
    - run pants list --changed-since=origin/main
    - run pants test --changed-since=origin/main


## Create a PEX binary
1. Add a pex_binary target for main.py:
    ```helloworld/BUILD
    python_sources()

    pex_binary(
      name="main_pex_binary",
      entry_point="main.py",
    )
    ```
2. Build the binary and package it:
    ```
    pants package helloworld:main_pex_binary
    ```
3. Inspect the resulting file in dist/ directory:

    ```
    unzip -l dist/helloworld/main_pex_binary.pex
    ```
4. Execute it:
    ```
    ./dist/helloworld/main_pex_binary.pex
    ```


## Build Docker image for main.py
Note this only works if you have installed pants locally, since pants needs access to the Docker daemon.
`unalias` pants
1. Create Dockerfile:

```bash
touch helloworld/Dockerfile
```
2. Paste the following into Dockerfile:
```
FROM python:3.9-slim
COPY helloworld/pex_binary.pex ./app
ENTRYPOINT ["./app"]
```

3. Add docker_image target to helloworld/BUILD:

```helloworld/BUILD
...

docker_image("main_docker_image")
```
4. Enable the docker backend in pants.toml:
```toml

backend_packages.add = [
  ...
  "pants.backend.docker"
]
```
5. Build the image:
```bash
pants package helloworld:main_docker_image
```

## Clean Up
```
docker rm --force pants-example-python
```
6. Show that the image exists locally:
```bash
docker images | grep main_docker_image
```
7. Run it:
```
docker run --rm main_docker_image 
```
