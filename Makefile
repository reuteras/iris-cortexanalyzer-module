#* Variables
SHELL := /usr/bin/env bash
PYTHON := python3.9
PYTHONPATH := `pwd`
VENV := .venv

# Virtuell environment
.PHONY: .venv
.venv:
	python3.9 -m venv "${VENV}"
	source .venv/bin/activate && python3.9 -m pip install -U pip

#* Installation
.PHONY: install
install: .venv
	source .venv/bin/activate && python3.9 -m pip install .

#* Build wheel
.PHONY: wheel
wheel: .venv
	source .venv/bin/activate && python3.9 -m pip wheel .

#* Uninstall
#* Installation
.PHONY: uninstall
uninstall:
	source .venv/bin/activate && python3.9 -m pip uninstall iris_cortexanalyzer_module

#* Cleanup
.PHONY: venv-remove
venv-remove:
	rm -rf .venv

.PHONY: wheel-remove
wheel-remove:
	find . | grep -E "iris_cortexanalyzer_module" | grep -E ".whl" | xargs rm -rf

.PHONY: egg-remove
egg-remove:
	find . | grep -E ".egg-info" | xargs rm -rf

.PHONY: build-remove
build-remove:
	rm -rf build/

.PHONY: dist-remove
dist-remove:
	rm -rf dist/

.PHONY: clean
clean: build-remove dist-remove egg-remove venv-remove wheel-remove
