echo "Preloading docker images..."
# Loading "tar" images...
for image in $(find "/tmp/.images/" -name '*.tar'); do
  echo "Loading $image..."
  docker image load -i "$image"
done
# Loading "tar.gz" images...
for image in $(find "/tmp/.images/" -name '*.tar.gz'); do
  echo "Loading $image..."
  gunzip -c "$image" | docker image load
done
