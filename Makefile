.PHONY: test clean

test:
	python3 scripts/run_tests.py

clean:
	rm -rf build
