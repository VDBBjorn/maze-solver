open("IN","80.svg") or die "error";
open("OUT",">","80-gekleurd.svg") or die "error";
$|=1;
my %in = ();
$rows=0;
$cols=0;
$teller=0;
while(<IN>) {
  if($_ =~ m/.*<title>(\d*) by (\d*).*<\/title>.*/g) {
    $rows = $2;
    $cols = $1;
  }
  elsif($_ =~ m/<line x1=\"(\d*)\" y1=\"(\d*)\" x2=\"(\d*)\" y2=\"(\d*)\"/g) {
    my %line = (
    x1 => $1/16,  #top
    x2 => $3/16,  #bottom
    y1 => $2/16,  #left
    y2 => $4/16   #right
    );
    $in{$teller} = \%line;
    $teller++;
  }
}

my %game=();
print "start\n";
for($i=1;$i<=$rows*$cols;$i++) {
  my %cel = (
    index => $i,
    row => int((($i-1)/($cols))+1),
    col => (($i-1)%$cols)+1,
    left => ($i-1),
    right => ($i+1),
    top => ($i-$cols),
    bottom => ($i+$cols)
  );
  if($cel{bottom}>$rows*$cols) {
    $cel{bottom} = 0;
  }
  if($cel{top}<1) {
    $cel{top} = 0;
  }
  if($i%($cols) == 0) {
    $cel{right} = 0;
  }
  if($i%($cols) == 1) {
    $cel{left} = 0;
  }
  $game{$i} = \%cel;
}
for $v (values %in) { #foreach line
  for $c (values %game) { #delete  top/bottom/left/right if no option
    if($c->{col} >= $v->{x1} && $c->{col}+1 <= $v->{x2} && $c->{row} == $v->{y1}) { #top
      #print "top: $v->{x1}, $v->{x2}, $v->{y1}, $v->{y2}\n";
      $c->{top} = -1;
    }
    if($c->{row} >= $v->{y1} && $c->{row}+1 <= $v->{y2} && $c->{col} == $v->{x1}) { #left
      #print "$c->{index}: $v->{x1}, $v->{x2}, $v->{y1}, $v->{y2}\n";
      $c->{left} = -1;
    }
    if($c->{row} >= $v->{y1} && $c->{row}+1 <= $v->{y2} && $c->{col}+1 == $v->{x1}) { #right
      #print "$v->{x1}, $v->{x2}, $v->{y1}, $v->{y2}\n";
      $c->{right} = -1;
    }
    if($c->{col} >= $v->{x1} && $c->{col}+1 <= $v->{x2} && $c->{row}+1 == $v->{y1}) { #bottom
      #print "$v->{x1}, $v->{x2}, $v->{y1}, $v->{y2}\n";
      $c->{bottom} = -1;
    }
  }
}
print "intermediate\n";
my @values = ();
for $g (values %game) {
  if($g->{left} == 0) {
    push @values, $g;
    $g->{left} = -1;
  }
  elsif ($g->{right} == 0) {
    push @values, $g;
    $g->{right} = -1;
  }
  elsif ($g->{top} == 0) {
    push @values, $g;
    $g->{top} = -1;
  }
  elsif ($g->{bottom} == 0) {
    push @values, $g;
    $g->{bottom} = -1;
  }
}
$start = @values[0];
$laatste = @values[1];
my %route = ();
my %stap = (
  cel => $start,
  volgende => 0,
  vorige => 0
);
$i = 0;
$route{$i}=\%stap;
my $current = \%stap;
my $einde = 0;
print "$current->{cel}->{left} $current->{cel}->{right} $current->{cel}->{top} $current->{cel}->{bottom}\n";
while($einde==0) {
  $i++;
  print "stap $i\t\t";
  if($current->{cel}->{index}==$laatste->{index}) {
    my %stap = (
      cel => $einde,
      volgende => 0,
      vorige => $current
    );
    $current->{volgende} = \%stap;
    $route{$i} = \%stap;
    $einde = 1;
    #print "einde!\n";
  }
  elsif($current->{cel}->{left} != undef && $current->{cel}->{left}>0 && $current->{vorige}->{cel}->{index} != $game{$current->{cel}->{left}}->{index}) {
    print "LEFT -> $game{$current->{cel}->{left}}->{index}\n";
    my %stap = (
      cel => $game{$current->{cel}->{left}},
      volgende => 0,
      vorige => $current
    );
    $current->{volgende} = \%stap;
    $current = \%stap;
    $route{$i} = $current;
  }
  elsif($current->{cel}->{right} != undef && $current->{cel}->{right}>0 && $current->{vorige}->{cel}->{index} != $game{$current->{cel}->{right}}->{index}) {
    print "RIGHT -> $game{$current->{cel}->{right}}->{index}\n";
    my %stap = (
      cel => $game{$current->{cel}->{right}},
      volgende => 0,
      vorige => $current
    );
    $current->{volgende} = \%stap;
    $current = \%stap;
    $route{$i} = $current;
  }
  elsif($current->{cel}->{top} != undef && $current->{cel}->{top}>0 && $current->{vorige}->{cel}->{index} != $game{$current->{cel}->{top}}->{index}) {
    print "TOP -> $game{$current->{cel}->{top}}->{index}\n";
    my %stap = (
      cel => $game{$current->{cel}->{top}},
      volgende => 0,
      vorige => $current
    );
    $current->{volgende} = \%stap;
    $current = \%stap;
    $route{$i} = $current;
  }
  elsif($current->{cel}->{bottom} != undef && $current->{cel}->{bottom}>0 && $current->{vorige}->{cel}->{index} != $game{$current->{cel}->{bottom}}->{index}) {
    print "BOTTOM -> $game{$current->{cel}->{bottom}}->{index}\n";
    my %stap = (
      cel => $game{$current->{cel}->{bottom}},
      volgende => 0,
      vorige => $current
    );
    $current->{volgende} = \%stap;
    $current = \%stap;
    $route{$i} = $current;
  }
  else {
    $wrongindex = $current->{cel}->{index};
    $current = $current->{vorige};
    delete $current->{volgende};
    $current->{volgende} = 0;
    if($current->{cel}->{left} == $wrongindex) {
      $current->{cel}->{left} = -2;
    }
    if($current->{cel}->{right} == $wrongindex) {
      $current->{cel}->{right} = -2;
    }
    if($current->{cel}->{top} == $wrongindex) {
      $current->{cel}->{top} = -2;
    }
    if($current->{cel}->{bottom} == $wrongindex) {
      $current->{cel}->{bottom} = -2;
    }
    #print "BACK\n";
  }
}

$it = \%stap;
seek IN, 0,0;
$gevonden=0;
while(<IN>) {
  if($gevonden) {
    $gevonden=0;
    print OUT "<g fill=\"red\" stroke=\"none\">\n";
    $it = \%stap;
    while($it->{volgende}!=0) {
      $c = $it->{cel}->{col}*16;
      $cp = $c+16;
      $r = $it->{cel}->{row}*16;
      $rp = $r+16;
      print OUT "<polygon points=\"$cp,$rp $cp,$r $c,$r $c,$rp\" \/>\n";
      $it = $it->{volgende};
    }
    print OUT "</g>\n"

  }
  else {
    if($_ =~ m/.*<title>.*/g) {
      $gevonden=1;
    }
  }
  print OUT $_;
}
