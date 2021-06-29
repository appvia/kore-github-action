.[][]
  as $item
  | select($desired[][] 
    | contains({
      kind: $item.kind,
      apiVersion: $item.apiVersion,
        metadata:{
          name: $item.metadata.name, 
          namespace:$item.metadata.namespace
        }
      } ) 
    | not  )