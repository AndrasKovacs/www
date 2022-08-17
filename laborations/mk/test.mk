# Test compilation of the stub under various GHC versions.

test-goals = \
  test-7.10.3 \
  test-8.0.2  \
  test-8.2.2  \
  test-8.4.4  \
  test-8.6.5  \
  test-8.8.4  \
  test-8.10.7 \
  test-9.0.2  \
  test-9.2.4  \
  test-9.4.1  \
# end test

test : $(test-goals)

clean-tests :
	@find . -name "test-*" -empty -delete

# EOF
