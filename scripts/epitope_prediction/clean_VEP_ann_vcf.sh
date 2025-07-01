source /projects/academic/rpili/tyler_venv/bin/activate

# Create an improved comprehensive VCF cleaning script
cat > clean_epitope_vcf_v2.py << 'EOF'
#!/usr/bin/env python3
import sys
import gzip
import re

def clean_annotation_field(field_value):
    """Clean any annotation field that contains '?' characters"""
    if not field_value or field_value == '':
        return ''
    
    # Handle patterns like "?-1/8553", "3107-?/3108", "1036-?/1035", etc.
    if '?' in field_value:
        # For range patterns like "1036-?/1035"
        if '/' in field_value and '-' in field_value:
            parts = field_value.split('/')
            numerator = parts[0]
            denominator = parts[1] if len(parts) > 1 else '1000'
            
            # Clean numerator (left side of /)
            if '?' in numerator:
                if '-' in numerator:
                    # Handle "?-1" -> "1", "3107-?" -> "3107", "1036-?" -> "1036"
                    nums = re.findall(r'\d+', numerator)
                    if nums:
                        numerator = nums[-1]  # Take the last number
                    else:
                        numerator = '1'  # Default fallback
                else:
                    # Handle standalone "?"
                    nums = re.findall(r'\d+', numerator)
                    if nums:
                        numerator = nums[0]
                    else:
                        numerator = '1'
            
            # Clean denominator (right side of /)
            if '?' in denominator:
                nums = re.findall(r'\d+', denominator)
                if nums:
                    denominator = nums[0]  # Take the first number
                else:
                    denominator = '1000'  # Default fallback
            
            return f"{numerator}/{denominator}"
        
        # For simple range patterns like "?-1"
        elif '-' in field_value:
            nums = re.findall(r'\d+', field_value)
            if nums:
                return nums[-1]  # Take the last number
            else:
                return '1'  # Default fallback
        
        # For standalone "?" or other patterns
        else:
            nums = re.findall(r'\d+', field_value)
            if nums:
                return nums[0]  # Take the first number
            else:
                return '1'  # Default fallback
    
    return field_value

def clean_vcf_line(line):
    """Clean a VCF line by fixing problematic CSQ annotations"""
    if not line.startswith('chr') or 'CSQ=' not in line:
        return line
    
    # Split the line
    parts = line.strip().split('\t')
    info_field = parts[7]
    
    # Extract and process CSQ field
    csq_match = re.search(r'CSQ=([^;]*)', info_field)
    if not csq_match:
        return line
    
    csq_content = csq_match.group(1)
    annotations = csq_content.split(',')
    
    cleaned_annotations = []
    for annotation in annotations:
        fields = annotation.split('|')
        
        # Clean specific fields that commonly contain '?' characters
        # Based on VEP CSQ format: https://www.ensembl.org/info/docs/tools/vep/vep_formats.html
        if len(fields) >= 16:  # Make sure we have enough fields
            # Field indices that commonly contain problematic '?' characters:
            # 12: cDNA_position
            # 13: CDS_position  
            # 14: Protein_position
            # 15: Amino_acids (sometimes)
            # 16: Codons (sometimes)
            
            for field_idx in [12, 13, 14, 15, 16]:
                if field_idx < len(fields):
                    fields[field_idx] = clean_annotation_field(fields[field_idx])
        
        cleaned_annotations.append('|'.join(fields))
    
    # Reconstruct the CSQ field
    new_csq = ','.join(cleaned_annotations)
    new_info = re.sub(r'CSQ=[^;]*', f'CSQ={new_csq}', info_field)
    parts[7] = new_info
    
    return '\t'.join(parts) + '\n'

def clean_vcf(input_file, output_file):
    """Clean the entire VCF file"""
    opener = gzip.open if input_file.endswith('.gz') else open
    mode = 'rt' if input_file.endswith('.gz') else 'r'
    
    lines_processed = 0
    lines_cleaned = 0
    
    with opener(input_file, mode) as infile, open(output_file, 'w') as outfile:
        for line_num, line in enumerate(infile, 1):
            lines_processed += 1
            
            if line.startswith('#'):
                outfile.write(line)
            else:
                try:
                    original_line = line
                    cleaned_line = clean_vcf_line(line)
                    
                    if cleaned_line != original_line:
                        lines_cleaned += 1
                    
                    outfile.write(cleaned_line)
                    
                except Exception as e:
                    print(f"Error processing line {line_num}: {e}", file=sys.stderr)
                    print(f"Problematic line: {line[:100]}...", file=sys.stderr)
                    # Skip problematic lines
                    continue
    
    print(f"VCF cleaning completed.", file=sys.stderr)
    print(f"Lines processed: {lines_processed}", file=sys.stderr)
    print(f"Lines cleaned: {lines_cleaned}", file=sys.stderr)
    print(f"Output written to {output_file}", file=sys.stderr)

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 clean_epitope_vcf_v2.py input.vcf.gz output.vcf")
        sys.exit(1)
    
    clean_vcf(sys.argv[1], sys.argv[2])
EOF

chmod +x clean_epitope_vcf_v2.py

# Clean your VCF file with the improved script
python3 clean_epitope_vcf_v2.py RCC_vs_DNA1.mutect2.filtered_VEP.ann.vcf.gz RCC_vs_DNA1.mutect2.filtered_VEP.ann.cleaned_v2.vcf

# Compress and index the cleaned VCF
bgzip RCC_vs_DNA1.mutect2.filtered_VEP.ann.cleaned_v2.vcf
tabix -p vcf RCC_vs_DNA1.mutect2.filtered_VEP.ann.cleaned_v2.vcf.gz
