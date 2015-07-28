#!perl

use strict;
use warnings;
use Data::Dumper;
use Math::GMP;
use Test::More;
use Config;

my ($f,$try,$x,$y,$ans,@tests,@data,@args,$ans1,$z,$line);

@data = <DATA>;
@tests = grep { ! /^&/ } @data;
plan tests => (scalar @tests + 10);

while (defined($line = shift @data)) {
	chomp $line;
	if ($line =~ s/^&//) {
		$f = $line;
		next;
	}
	@args = split(/:/,$line,99);
	$ans = pop(@args);

	if ( $args[0] =~ /^i([-+]?\d+)$/ ) {
		$try = "\$x = $1;";
	}
	elsif ( $args[0] =~ /^b([-+]?.+),([0-9]+)$/ ) {
		$try = "\$x = Math::GMP->new(\"$1\", $2);";
	}
	else {
		$try = "\$x = Math::GMP->new(\"$args[0]\");";
	}

	if ($f eq "bnorm") {
		$try .= "\$x+0;";
	}
	elsif ($f eq "fibonacci") {
		$try .= 'Math::GMP::fibonacci($x);';
	}
	elsif ($f eq "bfac") {
		$try .= '$x->bfac();';
	}
	elsif ($f eq "bneg") {
		$try .= "-\$x;";
	}
	elsif ($f eq "babs") {
		$try .= "abs \$x;";
	}
	elsif ($f eq "square_root") {
		$try .= 'Math::GMP::bsqrt($x);';
	}
	elsif ($f eq 'uintify') {
		$try .= "Math::GMP::uintify(\$x);";
		$ans = pop(@args) if ($Config{longsize} == 4 && scalar @args > 1);
	}
	elsif ($f eq 'intify') {
		$try .= "Math::GMP::intify(\$x);";
		$ans = pop(@args) if ($Config{longsize} == 4 && scalar @args > 1);
	}
	elsif ($f eq 'probab_prime') {
		my $rets = $args[1];
		$try .= "Math::GMP::probab_prime(\$x,$rets);";
	}
	elsif ($f eq 'new_from_base') {
		$try .= "\$x;";
	}
	else {
		if ( $args[1] =~ /^i([-+]?\d+)$/ ) {
			$try .= "\$y = $1;";
		}
		else {
			$try .= "\$y = Math::GMP->new(\"$args[1]\");";
		}
		if ($f eq 'bcmp') {
			$try .= "\$x <=> \$y;";
		}
		elsif ($f eq 'band') {
			$try .= "\$x & \$y;";
		}
		elsif ($f eq 'bxor') {
			$try .= "\$x ^ \$y;";
		}
		elsif ($f eq 'bior') {
			$try .= "\$x | \$y;";
		}
		elsif ($f eq 'blshift') {
			$try .= "\$x << \$y;";
		}
		elsif ($f eq 'brshift') {
			$try .= "\$x >> \$y;";
		}
		elsif ($f eq 'badd') {
			$try .= "\$x + \$y;";
		}
		elsif ($f eq 'bsub') {
			$try .= "\$x - \$y;";
		}
		elsif ($f eq 'bmul') {
			$try .= "\$x * \$y;";
		}
		elsif ($f eq 'bdiv') {
			$try .= "\$x / \$y;";
		}
		elsif ($f eq 'bmod') {
			$try .= "\$x % \$y;";
		}
		elsif ($f eq 'bdiv2a') {
			$try .= "((Math::GMP::bdiv(\$x, \$y))[0]);";
		}
		elsif ($f eq 'bdiv2b') {
			$try .= "((Math::GMP::bdiv(\$x, \$y))[1]);";
		}
		elsif ($f eq 'bgcd') {
			$try .= "Math::GMP::bgcd(\$x, \$y);";
		}
		elsif ($f eq 'gcd') {
			$try .= "Math::GMP::gcd(\$x, \$y);";
		}
		elsif ($f eq 'blcm') {
			$try .= "Math::GMP::blcm(\$x, \$y);";
		}
		elsif ($f eq 'bmodinv') {
			$try .= "Math::GMP::bmodinv(\$x, \$y);";
		}
		elsif ($f eq 'sizeinbase') {
			$try .= "Math::GMP::sizeinbase_gmp(\$x, \$y);";
		}
		elsif ($f eq 'add_ui') {
			$try .= "Math::GMP::add_ui_gmp(\$x, \$y); \$x";
		}
		elsif ($f eq 'mul_2exp') {
			$try .= "Math::GMP::mul_2exp_gmp(\$x, \$y);";
		}
		elsif ($f eq 'div_2exp') {
			$try .= "Math::GMP::div_2exp_gmp(\$x, \$y);";
		}
		elsif ($f eq 'mmod') {
			$try .= "Math::GMP::mmod_gmp(\$x, \$y);";
		}
		elsif ($f eq 'mod_2exp') {
			$try .= "Math::GMP::mod_2exp_gmp(\$x, \$y);";
		}
		elsif ($f eq 'legendre') {
			$try .= "Math::GMP::legendre(\$x, \$y);";
		}
		elsif ($f eq 'jacobi') {
			$try .= "Math::GMP::jacobi(\$x, \$y);";
		}
		elsif ($f eq 'test_bit') {
			$try .= "Math::GMP::gmp_tstbit(\$x, \$y);";
		}
		else {
			if ( $args[2] =~ /^i([-+]?\d+)$/ ) {
				$try .= "\$z = $1;";
			}
			else {
				$try .= "\$z = Math::GMP->new(\"$args[2]\");";
			}
			if ($f eq 'powm') {
				$try .= "Math::GMP::powm_gmp(\$x, \$y, \$z);";
			}
			else {
				warn "Unknown op";
			}
		}
	}
	$ans1 = eval $try;
	is( "$ans1", $ans, "Test worked: $try");

}

# Test of bfac as described in the pod

$x = Math::GMP->new(5);
my $val = $x->bfac();
is(int $val, 120, 'gfac gives expected result');

# some assorted tests for internal functions

$x = Math::GMP->new('123');
$y = Math::GMP::gmp_copy($x);
is (ref($y),ref($x), 'refs are the same');
is ("$y",'123', 'gmp_copy gives correct value');

{
	# boolean check should not fall back to truncating intify
	my $s = '1' . ('0' x 70);
	my $i1 = Math::GMP->new($s);
	is ($s, "$i1", 'new 1e70 from string is preserved');
	my $bool = $i1 ? 1 : 0;
	is ($bool, 1, '1e70 is boolean TRUE');
	my $i2 = Math::GMP->new($i1);  # has internal boolean check
	is ($s, "$i2", 'new 1e70 from object is preserved');
}

{
    # Test of blshift as described in the POD.
    my $x = Math::GMP->new('2');
    my $result = $x->blshift(4, 0);

    is ("$x", "2", "x stays the same.");
    is ("$result", "32", "Result is 2 << 4");
}

{
    # Test of brshift as described in the POD.
    my $x = Math::GMP->new('5');
    my $result = $x->brshift(1, 0);

    is ("$x", "5", "x stays the same.");
    is ("$result", "2", "Result is 2 << 4");
}

# all done

__END__
&bcmp
+0:0:0
-1:0:-1
+0:-1:1
+1:0:1
+0:1:-1
-1:1:-1
+1:-1:1
-1:-1:0
+1:1:0
+123:123:0
+123:12:1
+12:123:-1
-123:-123:0
-123:-12:-1
-12:-123:1
+123:124:-1
+124:123:1
-123:-124:1
-124:-123:-1
+100:5:1
i+100:5:1
+100:i5:1
i-10:-10:0
&badd
+0:0:0
+1:0:1
+0:1:1
+1:1:2
-1:0:-1
+0:-1:-1
-1:-1:-2
-1:1:0
+1:-1:0
+9:1:10
+99:1:100
+999:1:1000
+9999:1:10000
+99999:1:100000
+999999:1:1000000
+9999999:1:10000000
i+9999999:1:10000000
+99999999:1:100000000
+999999999:1:1000000000
+9999999999:1:10000000000
+99999999999:1:100000000000
+99999999999:i1:100000000000
+10:-1:9
+100:-1:99
+1000:-1:999
+10000:-1:9999
+100000:-1:99999
+1000000:-1:999999
+10000000:-1:9999999
+100000000:-1:99999999
+1000000000:-1:999999999
+10000000000:-1:9999999999
+123456789:987654321:1111111110
-123456789:987654321:864197532
-123456789:-987654321:-1111111110
+123456789:-987654321:-864197532
&bsub
+0:0:0
+1:0:1
+0:1:-1
+1:1:0
-1:0:-1
+0:-1:1
-1:-1:0
-1:1:-2
+1:-1:2
+9:1:8
+99:1:98
+999:1:998
+9999:1:9998
+99999:1:99998
+999999:1:999998
+9999999:1:9999998
+99999999:1:99999998
+999999999:1:999999998
+9999999999:1:9999999998
+99999999999:1:99999999998
+99999999999:i1:99999999998
+10:-1:11
+100:-1:101
+1000:-1:1001
+10000:-1:10001
+100000:-1:100001
+1000000:-1:1000001
+10000000:-1:10000001
+100000000:-1:100000001
+1000000000:-1:1000000001
+10000000000:-1:10000000001
+123456789:987654321:-864197532
-123456789:987654321:-1111111110
-123456789:-987654321:864197532
+123456789:-987654321:1111111110
i4:12345678987:-12345678983
&bmul
+0:0:0
+0:1:0
+1:0:0
+0:-1:0
-1:0:0
+123456789123456789:0:0
+0:123456789123456789:0
-1:-1:1
-1:1:-1
+1:-1:-1
+1:1:1
+2:3:6
-2:3:-6
+2:-3:-6
-2:-3:6
+111:111:12321
+10101:10101:102030201
+1001001:1001001:1002003002001
+100010001:100010001:10002000300020001
+10000100001:10000100001:100002000030000200001
+11111111111:9:99999999999
+11111111111:i9:99999999999
i9:+11111111111:99999999999
+22222222222:9:199999999998
+33333333333:9:299999999997
+44444444444:9:399999999996
+55555555555:9:499999999995
+66666666666:9:599999999994
+77777777777:9:699999999993
+88888888888:9:799999999992
+99999999999:9:899999999991
&bdiv2a
+0:1:0
+0:-1:0
+1:1:1
-1:-1:1
+1:-1:-1
-1:1:-1
+1:2:0
+2:1:2
+1000000000:9:111111111
+1000000000:i9:111111111
+2000000000:9:222222222
+3000000000:9:333333333
+4000000000:9:444444444
+5000000000:9:555555555
+6000000000:9:666666666
+7000000000:9:777777777
+8000000000:9:888888888
+9000000000:9:1000000000
+35500000:113:314159
+71000000:226:314159
+106500000:339:314159
+1000000000:3:333333333
+10:5:2
+100:4:25
+1000:8:125
+10000:16:625
i+10000:16:625
+999999999999:9:111111111111
+999999999999:99:10101010101
+999999999999:999:1001001001
+999999999999:9999:100010001
+999999999999999:99999:10000100001
&bdiv
+0:1:0
+0:-1:0
+1:1:1
-1:-1:1
+1:-1:-1
-1:1:-1
+1:2:0
+2:1:2
+1000000000:9:111111111
+1000000000:i9:111111111
+2000000000:9:222222222
+3000000000:9:333333333
+4000000000:9:444444444
+5000000000:9:555555555
+6000000000:9:666666666
+7000000000:9:777777777
+8000000000:9:888888888
+9000000000:9:1000000000
+35500000:113:314159
+71000000:226:314159
+106500000:339:314159
+1000000000:3:333333333
+10:5:2
+100:4:25
+1000:8:125
+10000:16:625
i+10000:16:625
+999999999999:9:111111111111
+999999999999:99:10101010101
+999999999999:999:1001001001
+999999999999:9999:100010001
+999999999999999:99999:10000100001
&bdiv2b
+0:1:0
+0:-1:0
+1:1:0
-1:-1:0
+1:-1:0
-1:1:0
+1:2:1
+2:1:0
+1000000000:9:1
+1000000000:i9:1
+2000000000:9:2
+3000000000:9:3
+4000000000:9:4
+5000000000:9:5
+6000000000:9:6
+7000000000:9:7
+8000000000:9:8
+9000000000:9:0
+35500000:113:33
i+35500000:113:33
+71000000:226:66
+106500000:339:99
+1000000000:3:1
+10:5:0
+100:4:0
+1000:8:0
+10000:16:0
+999999999999:9:0
+999999999999:99:0
+999999999999:999:0
+999999999999:9999:0
+999999999999999:99999:0
&bmod
+0:1:0
+0:-1:0
+1:1:0
-1:-1:0
+1:-1:0
-1:1:0
+1:2:1
+2:1:0
+1000000000:9:1
+1000000000:i9:1
+2000000000:9:2
+3000000000:9:3
+4000000000:9:4
+5000000000:9:5
+6000000000:9:6
+7000000000:9:7
+8000000000:9:8
+9000000000:9:0
+35500000:113:33
i+35500000:113:33
+71000000:226:66
+106500000:339:99
+1000000000:3:1
+10:5:0
+100:4:0
+1000:8:0
+10000:16:0
+999999999999:9:0
+999999999999:99:0
+999999999999:999:0
+999999999999:9999:0
+999999999999999:99999:0
&bgcd
+0:0:0
+0:1:1
+1:0:1
+1:1:1
+2:3:1
+3:2:1
+100:625:25
+4096:81:1
&gcd
+0:0:0
+0:1:1
+1:0:1
+1:1:1
+2:3:1
+3:2:1
+100:625:25
+4096:81:1
&blcm
+0:0:0
+0:1:0
+1:0:0
+1:1:1
+2:3:6
+3:2:6
+100:625:2500
+75600:5402250:129654000
&bmodinv
+0:1:0
+1:1:0
+2:3:2
+5:7:3
+999:1000:999
&new_from_base
0xff:255
0x2395fa:2332154
babcdefgh,36:808334348993
&sizeinbase
+5:i10:1
+9999999999:i16:9
-5000:i2:13
&uintify
+15:15
+9999999999:1410065407:9999999999
+99999999999:1215752191:99999999999
+999999999999:3567587327:999999999999
&add_ui
+999999:i1:1000000
+9999999:i1:10000000
+99999999:i1:100000000
&intify
+999999999:999999999
+9999999999:1410065407:9999999999
&mul_2exp
+9999:i9:5119488
+99999:i9:51199488
+0:i1:0
+1:i0:1
&div_2exp
+999999:i1111:0
+0:i1:0
&powm
+99999:999999:99:27
+1:1:1:0
+1:0:1:0
&mmod
+99999:100002:99999
+1:1:0
&mod_2exp
+99999999:11111:99999999
+0:1:0
&jacobi
+1:15:1
+1:15:1
+2:15:1
+3:15:0
+4:15:1
+5:15:0
+6:15:0
+7:15:-1
+8:15:1
+9:15:0
+10:15:0
+11:15:-1
+12:15:0
+13:15:-1
+14:15:-1
+15:15:0
&band
7:3:3
2:3:2
4:1:0
&bxor
7:3:4
2:3:1
4:1:5
&bior
7:3:7
2:3:3
4:1:5
&bfac
1:1
2:2
3:6
4:24
5:120
6:720
&fibonacci
2:1
3:2
4:3
5:5
6:8
7:13
8:21
9:34
10:55
&test_bit
10:0:0
1:0:1
3:1:1
3:2:0
&square_root
16:4
1:1
0:0
100:10
101:10
99:9
&probab_prime
5:10:2
6:10:0
&gcd
0:0:0
1:0:1
9:9:9
17:19:1
54:24:6
42:56:14
9:28:1
48:180:12
i48:i180:12
-30:-90:30
-3:-9:3
i-3:i-9:3
2705353758:2540073744:18
i2705353758:i2540073744:18
12848174105599691600:15386870946739346600:1400
9785375481451202685:17905669244643674637:117
921166566073002915606255698642:1168315374100658224561074758384:14
1214969109355385138343690512057521757303400673155500334102084:1112036111724848964580068879654799564977409491290450115714228:42996
745845206184162095041321:61540282492897317017092677682588744425929751009997907259657808323805386381007:1
&blcm
i1:i0:0
i0:i1:0
i17:i19:323
i54:i24:216
i36:i45:180
i-36:i-45:180
i-36:i-45:180
i36:i-45:180
i-36:i45:180
i3219664501:i2880273383:9273513964420276883
9999999998987:10000000001011:99999999999979999998975857
892478777297173184633:892478777297173184633:892478777297173184633
&jacobi
i109981:i737777:1
i737779:i121080:-1
i-737779:i121080:1
i737779:i-121080:-1
i-737779:i-121080:-1
i12345:i331:-1
i1001:i9907:-1
i19:i45:1
i8:i21:-1
i5:i21:1
i5:i1237:-1
i10:i49:1
i123:i4567:-1
i3:i18:0
i3:i-18:0
i-2:i0:0
i-1:i0:1
i0:i0:0
i1:i0:1
i2:i0:0
i-2:i1:1
i-1:i1:1
i0:i1:1
i1:i1:1
i2:i1:1
i-2:i-1:-1
i-1:i-1:-1
i0:i-1:1
i1:i-1:1
i2:i-1:1
i3686556869:i428192857:1
i-1453096827:i364435739:-1
i3527710253:i-306243569:1
i-1843526669:i-332265377:1
i321781679:i4095783323:-1
i454249403:i-79475159:-1
17483840153492293897:455592493:1
-1402663995299718225:391125073:1
16715440823750591903:-534621209:-1
13106964391619451641:16744199040925208803:1
11172354269896048081:10442187294190042188:-1
-5694706465843977004:9365273357682496999:-1
878944444444444447324234:216539985579699669610468715172511426009:-1
&probab_prime
3878888047:25:1
14811094489161957443:25:1
232959001450513754379792189108873634181:25:1
91824020991616815553147615676933454480045241423098328989602116468298297311309:25:1
8285396061339403252920302070391390891474883409843237347887428315444504156793935159055430946705757466964822392797379161103939327123077267166338215317904079:25:1
777777777777777777777777:25:0
890745785790123461234805903467891234681234:25:0
8041390271962017234692123621666121818392263837471332893549490730885083462618835990190315107479962729421426370683173686420981834217178353304525610906493143:25:0
1498370845232252488162599227507794675135574818583361091623468615853723670176324198216325177:25:0
2887148238050771212671429597130393991977609459279722700926516024197432303799152733116328983144639225941977803110929349655578418949441740933805615113979999421542416933972905423711002751042080134966731755152859226962916775325475044445856101949404200039904432116776619949629539250452698719329070373564032273701278453899126120309244841494728976885406024976768122077071687938121709811322297802059565867:25:0
&blshift
0:0:0
1:0:1
2:640:9124881235244390437282343211400582649786457014497119861158385035798550334417354773011825622634742799557284619147188814621377409442750875996505322639444428376503989348720529900165748384493207552
100:524:5491838128104487771985520639265114573815548240114644327515570767348434546718124841698047712529163643981837049113184686429697590399773315050059222632892045721600
&brshift
0:0:0
1:0:1
9124881235244390437282343211400582649786457014497119861158385035798550334417354773011825622634742799557284619147188814621377409442750875996505322639444428376503989348720529900165748384493207552:640:2
5491838128104487771985520639265114573815548240114644327515570767348434546718124841698047712529163643981837049113184686429697590399773315050059222632892045721600:524:100
50:1:25
3:1:1
