#* Variables
SHELL := /usr/bin/env bash
PYTHON := python3
PYTHONPATH := `pwd`
VENV := .venv

# Virtuell environment
.PHONY: .venv
.venv:
	python3 -m venv "${VENV}"
	. .venv/bin/activate && python3 -m pip install -U pip

#* Installation
.PHONY: install
install: .venv
	. .venv/bin/activate && python3 -m pip install .

#* Build wheel
.PHONY: wheel
wheel: .venv
	. .venv/bin/activate && python3 -m pip wheel .

#* Uninstall
#* Installation
.PHONY: uninstall
uninstall:
	. .venv/bin/activate && python3 -m pip uninstall iris_cortexanalyzer_module

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

.PHONY: clean
clean: build-remove egg-remove venv-remove wheel-remove
