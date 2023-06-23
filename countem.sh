#/usr/bin/env bash
RING=$1
GEAR=$2
LOOPS=1
if (($GEAR > $RING)); then
    echo "ERROR: Ring ($RING) must be at least as big as gear ($GEAR)"
    exit 1
fi

REMAINDER=$(($RING - $GEAR))
while (( $REMAINDER > 0 )); do
    if (($REMAINDER < $GEAR)); then
        REMAINDER=$(($REMAINDER + $RING))
    fi
    REMAINDER=$(($REMAINDER - $GEAR))
    LOOPS=$(($LOOPS + 1))
done

echo $LOOPS
exit 0
