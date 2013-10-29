#!/usr/bin/awk -f
BEGIN {
  values_stack[1] = 0
  text_stack_len = 0
  text_stack = ""
}

function pop(to){
  first = 1
  while(to<text_stack_len){
    if (verbose || first || last_value != values_stack[text_stack_len]) 
      if (lower_bound < values_stack[text_stack_len])
        print text_stack (first?"":".*"), values_stack[text_stack_len]
    

    last_value = values_stack[text_stack_len]
    first = 0
    values_stack[text_stack_len-1] += values_stack[text_stack_len]
    delete values_stack[text_stack_len]
    text_stack_len--
    text_stack = substr(text_stack,1,text_stack_len)
  }
}
      
      {
  key = $1
  value = NF>1?$2:1

  #find LCA
  lcp = 0
  while(lcp <= length(key) && lcp <= text_stack_len && substr(key,lcp+1,1) == substr(text_stack,lcp+1,1)){
    lcp++;
  }
  
  #go up to LCA
  pop(lcp)

  #go down to current node
  text_stack = substr(text_stack,1,text_stack_len) substr(key,lcp+1)
  while(text_stack_len < length(text_stack)){
    text_stack_len++
    values_stack[text_stack_len] = 0
  }
  text_stack_len = length(text_stack)+1;
  values_stack[text_stack_len] += value
}
END   {
  pop(0)
}
