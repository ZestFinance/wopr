xml.instruct!
xml.Response do
  xml.Play(digits: digits)
  xml.Pause(length: 10)
  xml.Say(loop: 0) do
    xml.text! "Yorn desh born, der ritt de gitt der gue, Orn desh, dee born desh, de umn bork! bork! bork!"
  end
end
