
all: dev clean test typecheck dists release

dev:
	pip install -q ".[dev]"

test:
	pytest --cov=followthemoney --cov-report html --cov-report term

typecheck:
	mypy --strict followthemoney

dist:
	python setup.py sdist bdist_wheel

release: clean dist
	twine upload dist/*

docker:
	docker build -t alephdata/followthemoney .

build: namespace default-model translate docker

namespace:
	python followthemoney/ontology.py docs/ns

default-model:
	ftm dump-model -o js/src/defaultModel.json

# initalize a new language:
# pybabel init -i followthemoney/translations/messages.pot -d followthemoney/translations -l de -D followthemoney
translate:
	pybabel extract -F babel.cfg -o followthemoney/translations/messages.pot followthemoney
	tx push --source
	tx pull --all
	pybabel compile -d followthemoney/translations -D followthemoney -f

clean:
	rm -rf dist build .eggs coverage-report .coverage
	find . -name '*.egg-info' -exec rm -fr {} +
	find . -name '*.egg' -exec rm -f {} +
	find . -name '*.pyc' -exec rm -f {} +
	find . -name '*.pyo' -exec rm -f {} +
