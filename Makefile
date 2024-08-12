.PHONY: install


install:
	poetry install --no-root
	poetry add hgvs || echo "This will fail, but will install the dependencies"
	# activate the virtual environment and run the remaining commands in a subshell
	( \
		. $$(poetry env info --path)/bin/activate; \
		pip install psycopg2-binary; \
		pip install --no-deps hgvs; \
		pip install biocommons.seqrepo; \
	)
	# reinstall deps again that were overwritten by the previous commands
	poetry install --no-root
