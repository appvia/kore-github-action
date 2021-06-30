def is_desired($item): 
  reduce ($desired[][] | contains({
    kind: $item.kind,
    apiVersion: $item.apiVersion,
      metadata:{
        name: $item.metadata.name, 
        namespace:$item.metadata.namespace
      }
  })) as $f ($item;  $f or . == true);
.[] | select(is_desired(.) | not)