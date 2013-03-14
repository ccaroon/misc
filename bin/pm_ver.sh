echo $1
echo perl -M$1 -e \'print \$$1::VERSION.\"\\n\"\'
perl -M$1 -e "print \$$1::VERSION.\"\n\""
